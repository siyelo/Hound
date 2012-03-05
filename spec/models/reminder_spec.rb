require 'spec_helper'

describe Reminder do
  before :each do
    ResqueSpec.reset!
  end

  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of :subject }
    it { should validate_presence_of :reminder_time }
    it { should validate_presence_of :user }
    it { should validate_presence_of :message_thread }
  end

  describe "overwritten accessors" do
    before :each do
      @reminder = Factory :reminder
    end

    it "should accept an array of cc's and return an array" do
      @reminder.cc = ['cc@example.com']
      @reminder.save
      @reminder.reload
      @reminder.cc.should == ['cc@example.com']
    end

    it "should accept a cc as a string and return an array" do
      @reminder.cc = 'cc@example.com'
      @reminder.save
      @reminder.reload
      @reminder.cc.should == ['cc@example.com']
    end

    it "should return an empty array if cc is nil" do
      @reminder.cc = nil
      @reminder.save
      @reminder.reload
      @reminder.cc.should == []
    end
  end

  describe "changed reminders" do
    it "should inform the recipients that the contents of the reminder have been changed" do
      method = :inform_other_recipients
      u = Factory :user
      r = Factory.build :reminder, user: u
      r.cc = ['pimpboiwonder@vuvuzela.com', 'snoopdawg@snoopy.com']
      r.save
      r.reminder_time = Time.now + 1.day
      r.save
      NotificationWorker.should have_queue_size_of(1)
      NotificationWorker.perform(r.id, method)
      unread_emails_for('snoopdawg@snoopy.com').size.should >= parse_email_count(1)
      unread_emails_for('pimpboiwonder@vuvuzela.com').size.should >= parse_email_count(1)
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
        SendConfirmationWorker.should have_queue_size_of(1)
        Queuer.add_to_send_queue(reminder)
        SendReminderWorker.should have_queue_size_of(1)
        email = SendReminderWorker.perform(reminder.id)
        reminder.reload.delivered?.should be_true
      end
    end

    describe "send emails" do
      before :each do
        reminder = Factory :reminder, subject: "mehpants"
        @email = UserMailer.send_reminder(reminder, reminder.email)
      end

      it "should append 'RE: ' before the emails subject" do
        @email.should have_subject(/Re: mehpants/)
      end
    end

    describe "snoozing" do
      before :each do
        @reminder = Factory.build :reminder
      end

      it "should generate a snooze token when creating a reminder" do
        @reminder.snooze_token.should be_nil
        @reminder.save
        @reminder.snooze_token.length.should == 8
      end

      it "should not regenerate the snooze token after a reminder has been snoozed" do
        @reminder.save
        old_token = @reminder.snooze_token
        @reminder.snooze_for("2days", old_token)
        @reminder.snooze_token.should == old_token
      end

      it "should snooze a reminder for a specified duration" do
        @reminder.reminder_time = Time.now
        @reminder.snooze_for('2days', @reminder.snooze_token)
        @reminder.reminder_time.should == Time.now + 2.days
      end

      it "should mark a snoozed reminder as undelivered" do
        @reminder.save
        Notifier.send_reminder_email(@reminder)
        @reminder.delivered?.should == true
        @reminder.snooze_for('2months', @reminder.snooze_token)
        @reminder.delivered?.should == false
      end

      it "should increment the snooze count as the user snoozes" do
        @reminder.snooze_count.should == 0 #sanity
        @reminder.save
        @reminder.snooze_for('2months', @reminder.snooze_token)
        @reminder.snooze_count.should == 1
      end
    end

    describe "cc'ed recipients" do
      it "should not include the snooze links for cc'ed users" do
        reminder = Factory :reminder, subject: "mehpants", cc: "wat@wiggle.com"
        @email = UserMailer.send_reminder(reminder, reminder.cc.first)
        @email.should_not have_body_text('/Snooze for:/')
      end
    end
  end
end
