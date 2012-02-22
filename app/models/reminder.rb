class Reminder < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  ### Associations
  belongs_to :user
  belongs_to :message_thread

  # Validations
  validates_presence_of :email, :subject, :reminder_time, :user, :message_thread

  ### Attributes
  attr_accessible :email, :subject, :reminder_time, :body, :cc_string,
    :sent_to, :cc, :user, :message_id, :delivered, :message_thread

  # Callbacks
  before_create :generate_snooze_token
  after_create :queue_confirmation_email

  ### Scopes

  scope :upcoming, where("reminder_time >= ? AND delivered = ?", Time.now, false)
  scope :completed, where("delivered = ?", true)
  scope :due_today, where("reminder_time >= ? AND reminder_time < ? AND delivered = ?",
                          Time.now, Date.tomorrow.to_datetime, false)
  scope :undelivered, where("reminder_time < ? AND delivered = ?", Time.now, false)
  scope :sorted, order("reminder_time ASC")

  ### Class methods
  def self.fetch_reminders
    time = Time.now.change(sec: 0)
    last_time = time + 59.seconds

    self.select("id, user_id").where("reminder_time >= ? AND reminder_time <= ? AND delivered = ?",
                                     time, last_time, false).includes(:user)
  end

  ### Instance methods

  def cc
    [*YAML::load(read_attribute(:cc))]
  end

  def cc=(cc)
    write_attribute(:cc, [*cc].to_yaml)
  end

  def add_to_send_queue
    Resque.enqueue(SendReminderWorker, id)
  end

  # sends emails to the people cc'd on an email when the main one is snoozed
  def add_to_snooze_to_notification_queue
    Resque.enqueue(NotificationWorker, id, :snooze_notification_email) unless self.cc.empty?
  end

  def snooze_notification_email
    self.cc.each do |recipient|
      UserMailer.send_notification_snooze(self, recipient).deliver
    end
  end

  # when a reminder is changed it adds an email to the recipients to the notification
  # queue to inform them of this change
  def add_change_reminder_to_notification_queue
    Resque.enqueue(NotificationWorker, id, :inform_other_recipients) unless self.cc.empty?
  end

  #informs the cc'd users of a change to the reminder
  def inform_other_recipients
    self.cc.each do |recipient|
      UserMailer.send_notification_of_change(self, recipient).deliver
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
      self.reminder_time = EmailParser::Dispatcher.parse_email(duration)
      self.snooze_count += 1
      self.delivered = false
      self.save!
    end
  end

  def formatted_reminder_time
    reminder_time.in_time_zone(user.timezone).to_formatted_s(:short_with_day)
  end

  def stripped_body
    body ? strip_tags(body) : ""
  end

  def cc_string
    cc.join(", ")
  end

  def cc_string=(cc_string)
    self.cc = cc_string.split(/[,;]\s*/)
  end

  private

  def queue_confirmation_email
    Resque.enqueue(SendConfirmationWorker, self.id) if user.confirmation_email?
  end

  def generate_snooze_token
    self.snooze_token = rand(36**8).to_s(36)
  end

end
