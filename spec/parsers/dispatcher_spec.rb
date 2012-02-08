require 'spec_helper'

describe EmailParser::Dispatcher do
  describe "parse addresses" do
    it "for adverbs" do
      emails = [Mail.new(from: 'pimp@macdaddy.yo',
                to: 'tomorrow@hound.cc',
                subject: 'test', date: DateTime.now)]
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.last.reminder_time.should == 1.day.from_now.change(hour: 8)
    end

    it "for incremental time" do
      Timecop.freeze
      emails = [Mail.new(from: 'pimp@macdaddy.yo',
                to: '2d8h3m@hound.cc',
                subject: 'test', date: DateTime.now)]
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.last.reminder_time.should == (8.hours + 3.minutes + 2.days).from_now
    end

    it "for a valid calendar time" do
      emails = [Mail.new(from: 'pimp@macdaddy.yo',
                to: '14February2013@hound.cc',
                subject: 'test', date: DateTime.now)]
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.last.reminder_time.should == DateTime.parse("14Feb2013").change(hour: 8)
    end

    it "for an invalid calendar time" do
      ResqueSpec.reset!
      Reminder.count.should == 0 #sanity
      emails = [Mail.new(from: 'pimpboiwonder@vuvuzela.com',
                to: 'aslkdjf@hound.cc',
                subject: 'test', date: DateTime.now)]
      EmailParser::Dispatcher.dispatch(emails)
      ErrorNotificationWorker.should have_queue_size_of(1)
      Reminder.count.should == 0
      ErrorNotificationWorker.perform(emails.first)
      unread_emails_for('pimpboiwonder@vuvuzela.com').size.should >= parse_email_count(1)
    end

  end

end
