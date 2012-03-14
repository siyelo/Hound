class Reminder < ActiveRecord::Base
  include ScopesReminders

  ### Associations
  belongs_to :user
  belongs_to :message_thread
  belongs_to :fetched_mail

  # Validations
  validates :send_at, presence: true
  validates :user, presence: true
  validates :fetched_mail, presence: true

  ### Attributes
  attr_accessible :user, :fetched_mail,
                  :sent_to, :send_at, :delivered, :is_bcc

  # Callbacks
  before_create :generate_snooze_token
  after_create :queue_confirmation_email
  after_update :queue_change_notification

  ### Instance methods

  delegate :subject, :subject=, to: :fetched_mail
  delegate :body, :body=, to: :fetched_mail

  def email #TODO PLS RENAME K THX
    fetched_mail.from.first
  end

  def cc
    is_bcc? ? [] : fetched_mail.all_addresses - HoundAddressList.new(fetched_mail)
  end

  def snooze_for(duration, token)
    if duration && snooze_token == token
      self.send_at = DateTime.parse_email(duration)
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

#TODO remove fields!
#
# == Schema Information
#
# Table name: reminders
#
#  id                :integer         not null, primary key
#  email             :string(255)
#  subject           :string(255)
#  body              :text
#  fetched_mail_id   :integer
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

