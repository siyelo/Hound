class Reminder < ActiveRecord::Base
  require 'parser'
  require 'SnoozeNotificationWorker' #don't know why this isn't being auto loaded

  ### Associations
  belongs_to :user

  # Validations
  validates_presence_of :email, :subject, :reminder_time, :user

  # Callbacks
  before_create :generate_snooze_token
  after_create :queue_confirmation_email

  ### Class methods
  def self.fetch_reminders
    time = Time.now.change(sec: 0)
    last_time = time + 59.seconds

    self.select("id, user_id").where("reminder_time >= ? AND reminder_time <= ? AND delivered = ?",
                                     time, last_time, false).includes(:user)
  end

  def self.upcoming_reminders_for(user)
    self.where("reminder_time >= ? AND delivered = ? AND user_id = ?", Time.now, false, user.id)
  end

  ### Instance methods

  def cc
    read_attribute(:cc) ? YAML::load(read_attribute(:cc)) : []
  end

  def cc=(cc)
    write_attribute(:cc, cc.class == Array ? cc.to_yaml : [cc].to_yaml)
  end

  def add_to_send_queue
    Resque.enqueue(SendReminderWorker, id)
  end

  # sends emails to the people cc'd on an email when the main one is snoozed
  def add_to_snooze_email_queue
    Resque.enqueue(SnoozeNotificationWorker, id) unless self.cc.empty?
  end

  def snooze_notification_email
    self.cc.each do |recipient|
      UserMailer.send_notification_snooze(self, recipient).deliver
    end
  end

  def send_confirmation_email
    UserMailer.send_confirmation(self).deliver
  end

  def send_reminder_email
    # this is necessary because we may have more than one worker polling
    unless delivered?
      (self.cc << self.email).each do |recipient|
        UserMailer.send_reminder(self,recipient).deliver
      end
      self.delivered = true
      self.save!
    end
  end

  def snooze_for(duration, token)
    if snooze_token == token
      self.reminder_time = EmailParser::Parser.parse_email(duration)
      self.snooze_count += 1
      self.delivered = false
      self.save!
    end
  end

  def formatted_reminder_time
    reminder_time.in_time_zone(user.timezone).to_formatted_s(:short_with_day)
  end

  private

  def queue_confirmation_email
    Resque.enqueue(SendConfirmationWorker, self.id) if user.confirmation_email?
  end

  def generate_snooze_token
    self.snooze_token = rand(36**8).to_s(36)
  end

end
