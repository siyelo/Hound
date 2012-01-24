class UserMailer < ActionMailer::Base
  default from: "reminder@mailshotbot.com"

  def send_reminder(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    reply_to = reminder.email == recipient ? "reminder@mailshotbot.com" : reminder.email
    mail(to: recipient, subject: "RE: #{reminder.subject}", reply_to: reply_to)
  end

  def send_confirmation(reminder)
    @reminder = reminder
    mail(:to => reminder.email, subject: "Confirmation: #{reminder.subject}")
  end
end
