require 'spec_helper'

describe Reminder do
  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of :subject }
    it { should validate_presence_of :reminder_time }
    it { should validate_presence_of :user }
  end
  context "workers" do
    describe "fetch_reminders" do
      it "should only get methods for the current minute" do
        Timecop.freeze(Time.now)
        correct_reminder = Factory :reminder, reminder_time: Time.now
        incorrect_reminer = Factory :reminder, reminder_time: Time.now + 1.hour
        incorrect_reminer2 = Factory :reminder, reminder_time: Time.now + 1.hour, delivered: true
        incorrect_reminder3 = Factory :reminder, reminder_time: Time.now, delivered: true
        reminders = Reminder.fetch_reminders
        reminders.size.should == 1
        reminders.first.id.should == correct_reminder.id
      end
    end

    describe "queueing" do
      it "should properly queue" do
        reminder = Factory :reminder
        reminder.add_to_send_queue
        SendMailWorker.should have_queue_size_of(1)
        email = SendMailWorker.perform(reminder.id)
        reminder.reload.delivered?.should be_true
      end
    end

    describe "send emails" do
      before :each do
        email = Factory :reminder, subject: "mehpants"
        @email = UserMailer.send_reminder(email)
      end

      it "should append 'RE: ' before the emails subject" do
          @email.should have_subject(/RE: mehpants/)
      end
    end
  end
end
