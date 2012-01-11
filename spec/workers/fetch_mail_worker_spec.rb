require 'spec_helper'

describe FetchMailWorker do
  describe 'it should check the account status' do
    before(:each) do
      reset_mailer
      Mail.stub(:all).and_return([Mail.new(from: 'sachin@siyelo.com',
                                           to: '2days@radmeet.cc',
                                           subject: 'test')])
    end

    it "should invite a user who isn't already registered" do
      FetchMailWorker.perform
      Reminder.all.count.should == 1
      User.all.count.should == 1
      unread_emails_for('sachin@siyelo.com').size.should >= parse_email_count(1)
    end

    it 'should not create a reminder if the user does not exist' do
      user = Factory(:user, :email => 'sachin@siyelo.com')
      FetchMailWorker.perform
      Reminder.all.count.should == 1
      unread_emails_for('sachin@siyelo.com').size.should == parse_email_count(0)
    end
  end
end
