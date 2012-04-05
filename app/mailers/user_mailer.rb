require 'active_support/time_with_zone'

class UserMailer < ActionMailer::Base
  default from: "reminder@hound.cc"

  # reminder with snooze and admin links
  def reminder(reminder, to)
    setup_reminder(reminder, to)
    mail(to: to, subject: "Re: #{reminder.subject}",
         in_reply_to: "<#{reminder.fetched_mail.message_id}>")
  end

  # reminder without snooze or admin links
  def recipient_reminder(reminder, to)
    setup_reminder(reminder, to)
    @owner = reminder.owner_recipient
    mail(to: to, subject: "Re: #{reminder.subject}",
         reply_to: @owner, in_reply_to: "<#{reminder.fetched_mail.message_id}>")
  end

  def confirmation(reminder, recipient = nil)
    recipient ||= reminder.owner_recipient
    @send_at = reminder.formatted_send_at
    @edit_reminder_url = edit_reminder_url(reminder.id)
    @disable_confirmations_url = confirmations_disable_url(token: reminder.user.modify_token)
    @original_subject = reminder.subject || "<No subject>"
    @user_active = reminder.user.active?

    #TODO smell - refactor
    if @user_active
      subject = "Confirmed: #{@original_subject}"
    else
      @activate_url = activate_url(
        invitation_token: reminder.user.invitation_token)
      subject = "Welcome to Hound.cc"
    end

    mail(:to => recipient, subject: subject,
         in_reply_to: "<#{reminder.fetched_mail.message_id}>")
  end

  def snooze(reminder, to)
    setup_reminder(reminder, to)
    @send_at = reminder.formatted_send_at
    @owner = reminder.owner_recipient
    mail(to: to, subject: "Re: #{reminder.subject}",
         reply_to: @owner, in_reply_to: "<#{reminder.fetched_mail.message_id}>")
  end

  def error(fetched_mail)
    @hounds = HoundAddressList.new(fetched_mail)
    @original_subject = fetched_mail.subject || "<No subject>"
    mail(to: fetched_mail.from, subject: "Date problem: #{@original_subject}",
         in_reply_to: "<#{fetched_mail.message_id}>")
  end

  private

  # common view setup for both reminders and recipient reminders
  def setup_reminder(reminder, to)
    @reminder = reminder
    @original_subject = reminder.subject || "<No subject>"
    @body = reminder.body.html_safe
    @created_at = reminder.created_at.strftime('%d-%b')
    @snoozed = reminder.snooze_count
  end
end
