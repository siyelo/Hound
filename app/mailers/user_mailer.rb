class UserMailer < ActionMailer::Base
  default from: "mailer@radmeet.cc"

  def send_reminder(email)
    mail(:to => email.email, :subject => mail.subject)
  end
end
