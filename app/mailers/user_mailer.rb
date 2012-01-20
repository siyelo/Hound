class UserMailer < ActionMailer::Base
  default from: "reminder@mailshotbot.com"

  def send_reminder(reminder)
    @reminder = reminder
    mail(:to => reminder.email, :subject => "RE: #{reminder.subject}")
  end
end
