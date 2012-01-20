class UserMailer < ActionMailer::Base
  default from: "coold00dette@sorad.cc"

  def send_reminder(reminder)
    @reminder = reminder
    mail(:to => reminder.email, :subject => "RE: #{reminder.subject}")
  end

  def send_confirmation(reminder)
    @reminder = reminder
    mail(:to => reminder.email, :subject => "Confirmation: #{reminder.subject}")
  end
end
