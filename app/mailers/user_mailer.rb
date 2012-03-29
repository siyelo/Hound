class UserMailer < ActionMailer::Base
  default from: "reminder@hound.cc"

  def send_reminder(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    reply_to = reminder.email == recipient ? "reminder@hound.cc" : reminder.email
    mail(to: recipient, subject: "Re: #{reminder.subject}",
         reply_to: reply_to, in_reply_to: "<#{reminder.fetched_mail.message_id}>")
  end

  def send_confirmation(reminder, recipient = nil)
    recipient ||= reminder.owner_recipient
    @send_at = reminder.send_at.in_time_zone(reminder.user.timezone)
    @edit_reminder_url = edit_reminder_url(reminder.id)
    @edit_notification_url = edit_notification_url(reminder.user.id,
                                                   token: reminder.user.modify_token)
    @user_active = reminder.user.active?

    #TODO smell - refactor
    if @user_active
      subject = "Confirmation"
    else
      @accept_user_invitation_url = accept_user_invitation_url(
        invitation_token: reminder.user.invitation_token)
      subject = "Welcome to Hound.cc"
    end

    mail(:to => recipient, subject: "#{subject}: #{reminder.subject}")
  end

  def send_snooze_notification(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    reply_to = reminder.email == recipient ? "reminder@hound.cc" : reminder.email
    mail(to: recipient, subject: "Re: #{reminder.subject}",
         reply_to: reply_to, in_reply_to: "<#{reminder.fetched_mail.message_id}>")
  end

  def send_error_notification(email)
    @email = email
    mail(to: email.from, subject: "Error: #{email.subject}",
         in_reply_to: "<#{email.message_id}>")
  end
end
