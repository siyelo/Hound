desc "Email test"
task :email_test => :environment do

  email    = ""
  password = ""
  total    = 10


  if email.blank? || password.blank?
    puts "!!! Please setup sender email and password in #{__FILE__}"
    exit
  end

  options = { :address              => "smtp.gmail.com",
              :port                 => 587,
              :domain               => "your.host.name",
              :user_name            => email,
              :password             => password,
              :authentication       => "plain",
              :enable_starttls_auto => true  }

  Mail.defaults do
    delivery_method :smtp, options
  end

  1.upto(total) do |index|
    puts "sending test email #{index}"

    mail = Mail.new do
      from     email
      to       "1d@hound.cc"
      subject  "test #{index}"
      body     "test #{index}"
    end

    mail.deliver!
  end
end
