require 'active_support/time_with_zone'

class UserMailer < ActionMailer::Base
  default from: "noreply@hound.cc"

  def send_reminder(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    reply_to = reminder.owner_recipient == recipient ? "reminder@hound.cc" : reminder.owner_recipient
    mail(to: recipient, subject: "Re: #{reminder.subject}",
         reply_to: reply_to, in_reply_to: "<#{reminder.fetched_mail.message_id}>")
  end

  def send_confirmation(reminder, recipient = nil)
    recipient ||= reminder.owner_recipient
    @send_at = reminder.formatted_send_at
    @edit_reminder_url = edit_reminder_url(reminder.id)
    @edit_notification_url = edit_notification_url(reminder.user.id,
                                                   token: reminder.user.modify_token)
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

    mail(:to => recipient, subject: subject)
  end

  def send_snooze_notification(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    reply_to = reminder.owner_recipient == recipient ? "reminder@hound.cc" : reminder.owner_recipient
    mail(to: recipient, subject: "Re: #{reminder.subject}",
         reply_to: reply_to, in_reply_to: "<#{reminder.fetched_mail.message_id}>")
  end

  def send_error_notification(fetched_mail)
    @hounds = HoundAddressList.new(fetched_mail)
    @original_subject = fetched_mail.subject || "<No subject>"
    mail(to: fetched_mail.from, subject: "Date problem: #{@original_subject}",
         in_reply_to: "<#{fetched_mail.message_id}>")
  end
end
