require 'spec_helper'

describe EmailParser::Dispatcher do

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
