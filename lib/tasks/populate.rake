namespace :db do
  desc "Create dummy reminders"
  task :populate => :environment do
    if Rails.env == 'development' || Rails.env == 'test'
      user = User.find_by_email('user@example.com')
      if user
        puts 'Found user with email: user@example.com'
      else
        puts 'Creating user: user@example.com'
        puts 'With password: password'
        puts '------------------------------------'
        user = User.new(email: 'user@example.com',
                        password: 'password',
                        timezone: 'Harare')
        user.save!
      end
      puts 'Creating 5 dummy reminders'
      (1..5).each do |index|
        mail = Mail.new(from: user.email,
                        to: "#{index}w@hound.cc",
                        subject: "Dummy reminder #{index}",
                        body: 'Test email')
        service = ReminderCreationService.new
        service.create!(mail)
      end
      puts '5 reminders successfully created'
    else
      puts "Dummy reminders cannot be created in the #{Rails.env} environment"
    end
  end
end
