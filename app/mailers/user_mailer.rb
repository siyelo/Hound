class UserMailer < ActionMailer::Base
  default from: "coold00dette@sorad.cc"

  def send_reminder(email)
    @email = email
    mail(:to => email.email, :subject => "RE: #{email.subject}")
  end
end
