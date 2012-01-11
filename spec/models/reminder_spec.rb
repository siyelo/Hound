require 'spec_helper'

describe Reminder do
  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of :subject }
    it { should validate_presence_of :reminder_time }
  end
  context "workers" do
    describe "fetch_reminders" do
      it "should only get methods for the current minute" do
        Timecop.freeze(Time.now)
        correct_reminder = Factory :reminder, reminder_time: Time.now
        incorrect_reminer = Factory :reminder, reminder_time: Time.now + 1.hour
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
      end
    end
  end
end
