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

  #TODO refactor into class methods
  scope :upcoming, where("reminder_time >= ? AND delivered = ?", Time.now, false)
  scope :completed, where("delivered = ?", true)
  scope :due_today, where("reminder_time >= ? AND reminder_time < ? AND delivered = ?",
                          Time.now, Date.tomorrow.to_datetime, false)
  scope :undelivered, where("reminder_time < ? AND delivered = ?", Time.now, false)
  scope :sorted, order("reminder_time ASC")

  class << self
    ### Named Scopes

    def due
      where("reminder_time < ?", Time.zone.now.change(sec: 59))
    end

    def unsent
       where("delivered = ?", false)
    end

    #TODO - refactor: we're diving too far into the user model here
    def with_active_user
      joins(:user).
      where("users.invitation_token IS NULL OR users.invitation_accepted_at IS NOT NULL")
    end
  end

  ### Instance methods

  def cc
    [*YAML::load(read_attribute(:cc))]
  end

  def cc=(cc)
    write_attribute(:cc, [*cc].to_yaml)
  end

  def body
    Base64::decode64(read_attribute(:body))
  end

  def body=(value)
    write_attribute(:body, Base64::encode64(value))
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
    self.snooze_token = Token.new(8)
  end

end
# == Schema Information
#
# Table name: reminders
#
#  id                :integer         not null, primary key
#  email             :string(255)
#  subject           :string(255)
#  body              :text(255)
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  reminder_time     :datetime
#  user_id           :integer
#  delivered         :boolean         default(FALSE)
#  snooze_token      :string(255)
#  snooze_count      :integer         default(0)
#  cc                :string(255)
#  message_id        :string(255)
#  message_thread_id :integer
#  sent_to           :string(255)
#

