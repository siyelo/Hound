class UserMailer < ActionMailer::Base
  default from: "mailer@radmeet.cc"

  def send_reminder(email)
    @email = email
    puts "SENDING THE FUDGING EMAIL"
    mail(:to => email.email, :subject => email.subject)
  end
end
