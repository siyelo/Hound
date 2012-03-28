require 'spec_helper_acceptance'

describe "confirmation emails" do
  before(:each) do
    ResqueSpec.reset!
    reset_mailer
    Mail.stub(:all).and_return([Mail.new(from: 'pimp@macdaddy.yo',
                                         to: '2days@hound.cc',
                                         subject: 'test', date: DateTime.now)])
  end

  context "existing users" do
    it "should receive a confirmation email" do
      user = Factory :user, email: 'pimp@macdaddy.yo'
      FetchMailJob.perform
      Reminder.all.count.should == 1 #sanity
      SendConfirmationJob.should have_queue_size_of(1)
      SendConfirmationJob.perform(Reminder.last.id)
      unread_emails_for('pimp@macdaddy.yo').size.should == parse_email_count(1)
    end

    it "should not receive an email if the user has disabled that in their settings" do
      user = Factory :user, email: 'pimp@macdaddy.yo', confirmation_email: false
      FetchMailJob.perform
      Reminder.all.count.should == 1 #sanity
      SendConfirmationJob.should have_queue_size_of(0)
    end
  end

  context "new users" do
    it "should send an invitation to new users" do
      FetchMailJob.perform
      Reminder.all.count.should == 1 #sanity
      SendConfirmationJob.should have_queue_size_of(1)
      SendConfirmationJob.perform(Reminder.last.id)
      unread_emails_for('pimp@macdaddy.yo').size.should == parse_email_count(1)
    end
  end

end
