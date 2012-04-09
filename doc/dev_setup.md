# Development setup

## Basic Setup

Run this in rails console to setup reminder for user@example.com

    mail = Mail.new(from: 'user@company.com', to: '1w@hound.cc', subject: 'hello', body: 'test')
    service = ReminderCreationService.new
    service.create!(mail)

## Start Redis

* redis-server /usr/local/etc/redis.conf


## To test emails locally

* Start mailcatcher locally

   $ mailcatcher

* Open http://localhost:1080

* From your rails console;

   $ rails console

    > UserMailer.confirmation(Reminder.last).deliver!

    > UserMailer.error(FetchedMail.last).deliver!

    > UserMailer.reminder(Reminder.last, 'g@g.com').deliver!

    > UserMailer.recipient_reminder(Reminder.last, 'g@g.com').deliver!

    > UserMailer.snooze(Reminder.last, 'g@g.com').deliver!

* If you make changes to the mail views, don't forget to type;

    > reload!

