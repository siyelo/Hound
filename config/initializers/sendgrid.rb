# below are the sendgrid app settings
if Rails.env == "production"
  ActionMailer::Base.delivery_method = :smtp

  ActionMailer::Base.smtp_settings = {
    :user_name => "siyelo",
    :password => "yHSeIRpYjiR4XDc2Gx",
    :domain => "sorad.cc",
    :address => "smtp.sendgrid.net",
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
  }
end
