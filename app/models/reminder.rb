class Reminder < ActiveRecord::Base
  include ScopesReminders

  ### Associations
  belongs_to :fetched_mail

  ### Attributes
  attr_accessible :fetched_mail, :sent_to, :send_at, :delivered, :other_recipients

  ### Serialized attributes
  serialize :other_recipients,  Array

  ### Validations
  validates :send_at, presence: true
  validates :fetched_mail, presence: true

  ### Callbacks
  before_create :generate_snooze_token

  ### Delegate methods
  delegate :subject, :subject=, to: :fetched_mail
  delegate :body, :body=, to: :fetched_mail
  delegate :user, :user=, to: :fetched_mail

  scope :old, lambda { where("send_at < ?", Time.now - 2.weeks) }
  scope :delivered, where(delivered: true)
  scope :uncleaned, where(cleaned: false)

  def owner_recipient
    fetched_mail.from
  end

  def other_recipients=(recipients_string_or_array)
    write_attribute(:other_recipients, EmailList.new(recipients_string_or_array))
  end

  def all_recipients
    [owner_recipient] + other_recipients
  end

  def snooze_for(duration, token)
    if duration && snooze_token == token
      self.send_at = EmailParser.parse(duration)
      self.snooze_count += 1
      self.delivered = false
      self.save!
    end
  end

  def formatted_send_at
    send_at.in_time_zone(fetched_mail.user.timezone).to_formatted_s(:rfc822_with_zone)
  end

  private
    def generate_snooze_token
      self.snooze_token = Token.new(8)
    end
end

# == Schema Information
#
# Table name: reminders
#
#  id               :integer         not null, primary key
#  email            :string(255)
#  other_recipients :string(255)
#  fetched_mail_id  :integer         indexed
#  send_at          :datetime
#  delivered        :boolean         default(FALSE), not null
#  snooze_token     :string(255)
#  snooze_count     :integer         default(0)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

