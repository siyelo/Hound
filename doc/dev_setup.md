# Development setup

## First of all start Redis

* redis-server /usr/local/etc/redis.conf


## Run Basic Email Setup

Run this in rails console to setup reminder for user@example.com

    mail = Mail.new(from: 'user@company.com', to: '1w@hound.cc', subject: 'hello', body: 'test')
    service = ReminderCreationService.new
    service.create!(mail)

## To test emails locally start Mailcatcher

* Start mailcatcher locally

   $ mailcatcher
   
## It's running on:

* Open http://localhost:1080

## To send actual emails:

* From your rails console;

   $ rails console

UserMailer.confirmation(Reminder.last).deliver!
UserMailer.error(FetchedMail.last).deliver!
UserMailer.reminder(Reminder.last, 'g@g.com').deliver!
UserMailer.recipient_reminder(Reminder.last, 'g@g.com').deliver!
UserMailer.snooze(Reminder.last, 'g@g.com').deliver!

* If you make changes to the mail views, don't forget to type;

    > reload!

