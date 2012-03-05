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
      emails = [Mail.new(from: 'pimp@macdaddy.yo',
                         to: '2d8h3m@hound.cc',
                         subject: 'test', date: DateTime.now)]
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.last.reminder_time.to_i.should == (8.hours + 3.minutes + 2.days).from_now.to_i
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

  context "multiple recipients" do
    before :each do
      reset_mailer
    end

    it "should create 1 reminder (to) " do
      emails = [Mail.new(from: 'sachin@siyelo.com',
                         to: ['2days@hound.cc'],
                         subject: 'test', date: DateTime.now)]

      Reminder.count.should == 0
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.count.should == 1
      Reminder.last.cc.should == []
    end

    it "should create 1 reminder (cc) " do
      emails = [Mail.new(from: 'sachin@siyelo.com',
                         to: 'anyone@example.com',
                         cc: '2days@hound.cc',
                         subject: 'test', date: DateTime.now)]

      Reminder.count.should == 0
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.count.should == 1
      Reminder.last.cc.should == ['anyone@example.com']
    end

    it "should create 1 reminder (bcc)" do
      emails = [Mail.new(from: 'sachin@siyelo.com',
                         to: 'anyone@example.com',
                         bcc: '2days@hound.cc',
                         subject: 'test', date: DateTime.now)]

      Reminder.count.should == 0
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.count.should == 1
      Reminder.last.cc.should == []
    end

    it "should create multiple reminders if @hound the 'to' and/or 'cc' field multiple times" do
      emails = [Mail.new(from: 'sachin@siyelo.com',
                         to: ['2days@hound.cc', '1min@hound.cc' ],
                         cc: ['1hour@hound.cc'],
                         subject: 'test', date: DateTime.now)]

      Reminder.count.should == 0
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.count.should == 3
    end

    it "should create multiple reminders if @hound in the 'to' and 'bcc' field multiple times" do
      emails = [Mail.new(from: 'sachin@siyelo.com',
                         to: ['2days@hound.cc', '1min@hound.cc' ],
                         cc: ['1hour@hound.cc'],
                         subject: 'test', date: DateTime.now)]

      Reminder.count.should == 0
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.count.should == 3
    end


    it "should not include @hound addresses in reminders' cc field" do
      emails = [Mail.new(from: 'sachin@siyelo.com',
                         to: ['2days@hound.cc'],
                         cc: ['1min@hound.cc', 'cc@example.com'],
                         subject: 'test', date: DateTime.now)]

      Reminder.count.should == 0
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.count.should == 2
      Reminder.first.cc.count.should == 1
      Reminder.first.cc.first.should == 'cc@example.com'
      Reminder.last.cc.count.should == 1
      Reminder.last.cc.first.should == 'cc@example.com'
    end

    it "reminder cc should be empty if hound was bcc'ed" do
      emails = [Mail.new(from: 'sachin@siyelo.com',
                         to: ['anyone@anyone.com'],
                         cc: ['wat@huh.com'],
                         bcc: ['1min@hound.cc'],
                         subject: 'test', date: DateTime.now)]

      Reminder.count.should == 0
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.count.should == 1
      Reminder.first.cc.count.should == 0
    end

    it "reminder cc should be empty if hound was bcc'ed" do
      emails = [Mail.new(from: 'sachin@siyelo.com',
                         to: ['1hour@hound.cc'],
                         cc: ['wat@huh.com'],
                         bcc: ['1min@hound.cc'],
                         subject: 'test', date: DateTime.now)]

      Reminder.count.should == 0
      EmailParser::Dispatcher.dispatch(emails)
      Reminder.count.should == 2
      Reminder.find_by_sent_to('1hour@hound.cc').cc.count.should == 1
      Reminder.find_by_sent_to('1min@hound.cc').cc.count.should == 0
    end

  end

  context 'message threads' do
    describe 'replies to the same thread' do
      before :each do
        @root = Mail.new(from: 'sachin@siyelo.com',
                         cc: ['cc@mail.com'],
                         to: ['2days@hound.cc'],
                         message_id: '1234',
                         subject: 'test', date: DateTime.now)

        @child = Mail.new(from: 'cc@mail.com',
                          cc: ['sachin@siyelo.com'],
                          to: ['2days@hound.cc'],
                          in_reply_to: '1234',
                          message_id: '5678',
                          subject: 'test', date: DateTime.now)

      end

      it 'should not create a new reminder if hound recipients havent changed' do
        emails = [@root, @child]
        EmailParser::Dispatcher.dispatch(emails)
        Reminder.count.should == 1
        MessageThread.count.should == 2
      end

      it 'should create a new reminder if hound recipients have changed' do
        @child.to = ['1min@hound.cc']
        emails = [@root, @child]
        EmailParser::Dispatcher.dispatch(emails)
        Reminder.count.should == 2
        MessageThread.count.should == 2
      end

      it 'should create a new reminder if one of many hound recipients changed' do
        @root.to = ['5min@hound.cc', '10min@hound.cc']
        @child.to = ['5min@hound.cc', '8days@hound.cc']
        emails = [@root, @child]
        EmailParser::Dispatcher.dispatch(emails)
        Reminder.count.should == 3
        MessageThread.count.should == 2
      end

      it 'should find an existing thread' do
        message = Factory :message_thread, message_id: '1234'
        Factory :reminder, message_thread: message, sent_to: '2days@hound.cc'
        emails = [@child]
        EmailParser::Dispatcher.dispatch(emails)
        Reminder.count.should == 1
        MessageThread.count.should == 2
      end
    end
  end
end
