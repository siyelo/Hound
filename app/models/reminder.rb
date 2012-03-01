class Reminder < ActiveRecord::Base

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
  after_update :queue_change_notification

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

    self.select("id, user_id").where("reminder_time >= ?
                                     AND reminder_time <= ? AND delivered = ?",
                                     time, last_time, false).includes(:user)
  end

  ### Instance methods

  def cc
    [*YAML::load(read_attribute(:cc))]
  end

  def cc=(cc)
    write_attribute(:cc, [*cc].to_yaml)
  end

  def cc_string
    cc.join(", ")
  end

  def cc_string=(cc_string)
    self.cc = cc_string.split(/[,;]\s*/)
  end

  def formatted_date
    reminder_time.strftime('%Y-%m-%d')
  end

  def formatted_time
    reminder_time.strftime('%R')
  end

  def snooze_for(duration, token)
    if duration && snooze_token == token
      self.reminder_time = EmailParser::Dispatcher.parse_email(duration)
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
    Queuer.queue_confirmation_email(self)
  end

  def queue_change_notification
    Queuer.queue_change_notification(self)
  end

  def generate_snooze_token
    self.snooze_token = rand(36**8).to_s(36)
  end

end
