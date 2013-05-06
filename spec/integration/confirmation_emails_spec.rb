require 'spec_helper_acceptance'

describe "confirmation emails", type: :request do
  before(:each) do
    ResqueSpec.reset!
    reset_mailer
  end

  def store_fetched_mail
    mail = Mail.new(from: 'pimp@macdaddy.yo',
                    to: '2days@hound.cc',
                   subject: 'test', date: DateTime.now)
    service = ReminderCreationService.new
    service.create!(mail)
  end

  context "existing users" do
    it "should receive a confirmation email" do
      user = FactoryGirl.create :user, email: 'pimp@macdaddy.yo'
      store_fetched_mail
      Reminder.all.count.should == 1 #sanity
      SendConfirmationJob.should have_queue_size_of(1)
      SendConfirmationJob.perform(Reminder.last.id)
      unread_emails_for('pimp@macdaddy.yo').size.should == parse_email_count(1)
    end

    it "should not receive an email if the user has disabled that in their settings" do
      user = FactoryGirl.create :user, email: 'pimp@macdaddy.yo', confirmation_email: false
      store_fetched_mail
      Reminder.all.count.should == 1 #sanity
      SendConfirmationJob.should have_queue_size_of(0)
    end
  end

  context "new users" do
    it "should send an invitation to new users" do
      store_fetched_mail
      Reminder.all.count.should == 1 #sanity
      SendConfirmationJob.should have_queue_size_of(1)
      SendConfirmationJob.perform(Reminder.last.id)
      unread_emails_for('pimp@macdaddy.yo').size.should == parse_email_count(1)
    end
  end
end
