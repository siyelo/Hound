require 'spec_helper'

describe FetchMailWorker do
  describe 'it should check the account status' do
    before(:each) do
      Mail.stub(:all).and_return([Mail.new(from: 'sachin@siyelo.com', subject: 'test')])
      EmailParser::Parser.stub(:parse_email).and_return(Time.now)
    end

    it "should invite a user who isn't already registered" do
      FetchMailWorker.perform
      Reminder.all.count.should == 1
    end

    it 'should not create a reminder if the user does not exist' do
      user = Factory(:user, :email => 'sachin@siyelo.com')
      FetchMailWorker.perform
      Reminder.all.count.should == 1
    end

  end


end
