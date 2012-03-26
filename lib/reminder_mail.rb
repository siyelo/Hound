require 'active_support/core_ext/module/delegation'

# Presenter for Reminders & Mail entities
class ReminderMail
  attr_accessor :reminder, :fetched_mail, :errors

  delegate :subject, :body, to: :fetched_mail
  delegate :send_at, :delivered?, to: :reminder

  def initialize(reminder, errors = {})
    @reminder = reminder
    @errors = errors
    @fetched_mail = @reminder.fetched_mail if @reminder
  end

  def cc
    @reminder.is_bcc? ? [] : reminder_or_fetched_mail_cc
  end

  def to
    @fetched_mail.from
  end

  def all_recipients
    [to] + cc
  end

  private

  def reminder_or_fetched_mail_cc
    @reminder.cc.empty? ? fetched_mail_cc : @reminder.cc
  end

  def fetched_mail_cc
    @fetched_mail.all_addresses - HoundAddressList.new(@fetched_mail)
  end
end

