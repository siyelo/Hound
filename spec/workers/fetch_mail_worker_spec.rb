require 'spec_helper'

describe FetchMailWorker do

  context "multiple recipients" do
    before :each do
      reset_mailer
    end

    it "should create 1 reminder (to) " do
      Mail.stub(:all).and_return([Mail.new(from: 'sachin@siyelo.com',
                                           to: ['2days@hound.cc'],
                                           subject: 'test', date: DateTime.now)])

      Reminder.count.should == 0
      FetchMailWorker.perform
      Reminder.count.should == 1
      Reminder.last.cc.should == []
    end

    it "should create 1 reminder (cc) " do
      Mail.stub(:all).and_return([Mail.new(from: 'sachin@siyelo.com',
                                           to: 'anyone@example.com',
                                           cc: '2days@hound.cc',
                                           subject: 'test', date: DateTime.now)])

      Reminder.count.should == 0
      FetchMailWorker.perform
      Reminder.count.should == 1
      Reminder.last.cc.should == ['anyone@example.com']
    end


    it "should create multiple reminders if @hound the 'to' and/or 'cc' field multiple times" do
      Mail.stub(:all).and_return([Mail.new(from: 'sachin@siyelo.com',
                                           to: ['2days@hound.cc', '1min@hound.cc' ],
                                           cc: ['1hour@hound.cc'],
                                           subject: 'test', date: DateTime.now)])

      Reminder.count.should == 0
      FetchMailWorker.perform
      Reminder.count.should == 3
    end

    it "should not include @hound addresses in reminders' cc field" do
      Mail.stub(:all).and_return([Mail.new(from: 'sachin@siyelo.com',
                                           to: ['2days@hound.cc'],
                                           cc: ['1min@hound.cc', 'cc@example.com'],
                                           subject: 'test', date: DateTime.now)])

      Reminder.count.should == 0
      FetchMailWorker.perform
      Reminder.count.should == 2
      Reminder.first.cc.count.should == 1
      Reminder.first.cc.first.should == 'cc@example.com'
      Reminder.last.cc.count.should == 1
      Reminder.last.cc.first.should == 'cc@example.com'
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
        Mail.stub(:all).and_return([@root, @child])
        FetchMailWorker.perform
        Reminder.count.should == 1
        MessageThread.count.should == 2
      end

      it 'should create a new reminder if hound recipients have changed' do
        @child.to = ['1min@hound.cc']
        Mail.stub(:all).and_return([@root, @child])
        FetchMailWorker.perform
        Reminder.count.should == 2
        MessageThread.count.should == 2
      end

      it 'should create a new reminder if one of many hound recipients changed' do
        @root.to = ['5min@hound.cc', '10min@hound.cc']
        @child.to = ['5min@hound.cc', '8days@hound.cc']
        Mail.stub(:all).and_return([@root, @child])
        FetchMailWorker.perform
        Reminder.count.should == 3
        MessageThread.count.should == 2
      end

      it 'should find an existing thread' do
        message = Factory :message_thread, message_id: '1234'
        Factory :reminder, message_thread: message, sent_to: '2days@hound.cc'
        Mail.stub(:all).and_return([@child])
        FetchMailWorker.perform
        Reminder.count.should == 1
        MessageThread.count.should == 2
      end
    end
  end
end
