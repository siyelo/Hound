require 'spec_helper'

describe Reminder do
  before :each do
    ResqueSpec.reset!
  end

  describe "validations" do
    it { should validate_presence_of :send_at }
    it { should validate_presence_of :user }
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

    it "should allow multiple cc's to be created with a string" do
      @reminder.cc = 'cc@abc.com, cc1@abc.com'
      @reminder.save
      @reminder.reload
      @reminder.cc.should == ['cc@abc.com', 'cc1@abc.com']
    end
  end

  describe "changed reminders" do
    it "should inform the recipients that the contents of the reminder have been changed" do
      method = :inform_other_recipients
      u = Factory :user
      r = Factory.build :reminder, user: u
      r.cc = ['pimpboiwonder@vuvuzela.com', 'snoopdawg@snoopy.com']
      r.save
      r.send_at = Time.zone.now + 1.day
      r.save
      NotificationWorker.should have_queue_size_of(1)
      NotificationWorker.perform(r.id, method)
      unread_emails_for('snoopdawg@snoopy.com').size.should >= parse_email_count(1)
      unread_emails_for('pimpboiwonder@vuvuzela.com').size.should >= parse_email_count(1)
    end
  end


  ## scopes
    it "should fetch ready to send reminders" do
      now = Time.now
      past_unsent_reminder = Factory :reminder, send_at: now - 1.hour
      due_reminder = Factory :reminder, send_at: now
      future_unsent_reminder = Factory :reminder, send_at: now + 1.hour
      reminders = Reminder.ready_to_send.sorted
      reminders.first.id.should == past_unsent_reminder.id
      reminders.second.id.should == due_reminder.id
    end

    it "should fetch from active users" do
      now = Time.now
      r = Factory :reminder, send_at: now
      reminders = Reminder.with_active_user
      reminders.first.id.should == r.id
    end

    it "should fetch upcoming reminders" do
      now = Time.now
      due_reminder = Factory :reminder, send_at: now - 1.hour
      future_unsent_reminder = Factory :reminder, send_at: now + 1.hour
      reminders = Reminder.upcoming.sorted
      reminders.first.id.should == future_unsent_reminder.id
    end

    it "should fetch completed reminders" do
      now = Time.now
      r = Factory :reminder
      r2 = Factory :reminder, delivered: true
      reminders = Reminder.completed
      reminders.first.id.should == r2.id
    end

  context "workers" do

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
        now = Time.zone.now
        @reminder.send_at = now
        @reminder.snooze_for('2days', @reminder.snooze_token)
        @reminder.send_at.to_i.should == (now + 2.days).to_i #Ruby times have greater precision
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

    it "should save with bad encoding" do
      r = Factory :reminder
      r.body = "\xA0bad encoding \xA0/"
      lambda do
        r.save!
      end.should_not raise_exception
    end
  end
end
