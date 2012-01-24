class UserMailer < ActionMailer::Base
  default from: "reminder@mailshotbot.com"

  def send_reminder(reminder, recipient)
    @reminder = reminder
    @recipient = recipient
    mail(:bcc => recipient, :subject => "RE: #{reminder.subject}")
  end

  def send_confirmation(reminder)
    @reminder = reminder
    mail(:to => reminder.email, :subject => "Confirmation: #{reminder.subject}")
  end
end
