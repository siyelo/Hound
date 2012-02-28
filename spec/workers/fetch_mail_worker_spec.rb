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
  end
end
