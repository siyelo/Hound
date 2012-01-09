class UserMailer < ActionMailer::Base
  default from: "mailer@radmeet.cc"

  def send_reminder(mail)
    mail(:to => mail.email, :subject => mail.subject)
  end
end
