class Reminder < ActiveRecord::Base
  include ReminderScopes

  ### Associations
  belongs_to :user
  belongs_to :message_thread

  # Validations
  validates_presence_of :email, :subject, :send_at, :user, :message_thread

  ### Attributes
  attr_accessible :email, :subject, :send_at, :body, :sent_to, :cc, :user,
    :message_id, :delivered, :message_thread

  # Callbacks
  before_create :generate_snooze_token
  after_create :queue_confirmation_email
  after_update :queue_change_notification

  ### Instance methods

  def cc
    [*YAML::load(read_attribute(:cc))]
  end

  def cc=(cc)
    write_attribute(:cc, EmailList.new(cc).to_yaml)
  end

  def body
    Base64::decode64(read_attribute(:body))
  end

  def body=(value)
    write_attribute(:body, Base64::encode64(value))
  end

  def snooze_for(duration, token)
    if duration && snooze_token == token
      self.send_at = EmailParser::Dispatcher.parse_email(duration)
      self.snooze_count += 1
      self.delivered = false
      self.save!
    end
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
#  body              :text
#  created_at        :datetime        not null
#  updated_at        :datetime        not null
#  send_at           :datetime
#  user_id           :integer
#  delivered         :boolean         default(FALSE), not null
#  snooze_token      :string(255)
#  snooze_count      :integer         default(0)
#  cc                :string(255)
#  message_id        :string(255)
#  message_thread_id :integer
#  sent_to           :string(255)
#

