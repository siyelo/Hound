require 'spec_helper'

describe Reminder do
  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of :subject }
    it { should validate_presence_of :reminder_time }
    it { should validate_presence_of :user }
  end

  context "overwritten accessors" do
    describe "cc" do
      reminder = Factory :reminder
      reminder.cc = ['cc@example.com']
      reminder.save
      reminder.reload
      reminder.cc.should == ['cc@example.com']
    end
  end

  context "workers" do
    describe "fetch_reminders" do
      it "should only get reminders for the current minute" do
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

    describe "snoozing" do
      before :each do
        @reminder = Factory.build :reminder
      end

      it "should generate a snooze token when creating a reminder" do
        @reminder.snooze_token.should be_nil
        @reminder.save
        @reminder.snooze_token.should_not be_nil
      end

      it "should regenerate the snooze token after a reminder has been snoozed" do
        @reminder.save
        old_token = @reminder.snooze_token
        @reminder.snooze_for("2days", old_token)
        @reminder.snooze_token.should_not == old_token
      end

      it "should snooze a reminder for a specified duration" do
        @reminder.reminder_time = Time.now
        @reminder.snooze_for('2days', @reminder.snooze_token)
        @reminder.reminder_time.should == Time.now + 2.days
      end

      it "should mark a snoozed reminder as undelivered" do
        @reminder.save
        @reminder.send_reminder_email
        @reminder.delivered?.should == true
        @reminder.snooze_for('2months', @reminder.snooze_token)
        @reminder.delivered?.should == false
      end
    end
  end
end
