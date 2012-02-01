class UserMailer < ActionMailer::Base
  default from: "reminder@mailshotbot.com"

  def send_reminder(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    reply_to = reminder.email == recipient ? "reminder@mailshotbot.com" : reminder.email
    mail(to: recipient, subject: "Re: #{reminder.subject}",
         reply_to: reply_to, in_reply_to: "<#{reminder.message_id}>")
  end

  def send_confirmation(reminder)
    @reminder = reminder
    mail(:to => reminder.email, subject: "Confirmation: #{reminder.subject}")
  end

  def send_notification_snooze(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    reply_to = reminder.email == recipient ? "reminder@mailshotbot.com" : reminder.email
    mail(to: recipient, subject: "Re: #{reminder.subject}",
         reply_to: reply_to, in_reply_to: "<#{reminder.message_id}>")
  end

  def send_notification_of_change(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    reply_to = reminder.email == recipient ? "reminder@mailshotbot.com" : reminder.email
    mail(to: recipient, subject: "Re: #{reminder.subject}",
         reply_to: reply_to, in_reply_to: "<#{reminder.message_id}>")
  end
end
