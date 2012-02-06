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
end
