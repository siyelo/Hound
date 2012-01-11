# below are the sendgrid app settings
ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :user_name => "petersiyelo",
  :password => "sendgridpassword",
  :domain => "sorad.cc",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}

