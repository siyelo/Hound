class Reminder < ActiveRecord::Base
  require 'parser'

  ### Associations
  belongs_to :user

  # Validations
  validates_presence_of :email, :subject, :reminder_time, :user

  # Callbacks
  before_save :generate_snooze_token
  after_create :queue_confirmation_email

  ### Class methods
  def self.fetch_reminders
    time = Time.now.change(sec: 0)
    last_time = time + 59.seconds

    self.select("id, user_id").where("reminder_time >= ? AND reminder_time <= ? AND delivered = ?",
      time, last_time, false).includes(:user)
  end

  ### Instance methods
  def add_to_send_queue
    Resque.enqueue(SendReminderWorker, self.id)
  end

  def send_confirmation_email
    UserMailer.send_confirmation(self).deliver
  end

  def send_reminder_email
    # this is necessary because we may have more than one worker polling
    unless delivered?
      UserMailer.send_reminder(self).deliver
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

  private

  def queue_confirmation_email
    Resque.enqueue(SendConfirmationWorker, self.id)
  end

  def generate_snooze_token
    if new_record? || reminder_time_changed?
      self.snooze_token = rand(36**8).to_s(36)
    end
  end

end
