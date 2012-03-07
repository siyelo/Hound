class Reminder < ActiveRecord::Base
  include ScopesReminders

  ### Associations
  belongs_to :message_thread
  belongs_to :fetched_mail

  ### Attributes
  attr_accessible :fetched_mail, :sent_to, :send_at, :delivered, :is_bcc

  ### Validations
  validates :send_at, presence: true
  validates :fetched_mail, presence: true

  ### Callbacks
  before_create :generate_snooze_token

  ### Delegate methods
  delegate :subject, :subject=, to: :fetched_mail
  delegate :cc, :cc=, to: :fetched_mail
  delegate :body, :body=, to: :fetched_mail
  delegate :user, :user=, to: :fetched_mail

  def email #TODO PLS RENAME K THX
    fetched_mail.from.first
  end

  def snooze_for(duration, token)
    if duration && snooze_token == token
      self.send_at = EmailParser.parse(duration)
      self.snooze_count += 1
      self.delivered = false
      self.save!
    end
  end

  private
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

