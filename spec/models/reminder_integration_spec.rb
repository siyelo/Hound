require 'spec_helper'

describe Reminder do
  it { should validate_presence_of :send_at }
  it { should validate_presence_of :fetched_mail }
  it { should belong_to :fetched_mail }

  it "should delegate simple fields to the associated mail (reading)" do
    mail = Factory :fetched_mail
    r = Factory :reminder, fetched_mail: mail
    r.subject.should == mail.subject
    r.body.should == mail.body
  end

  it "should delegate simple fields to the associated mail (writing)" do
    mail = Factory :fetched_mail
    r = Factory :reminder, fetched_mail: mail
    r.subject = '123'
    r.subject.should == '123'
    r.body = '456'
    r.body.should == '456'
  end

  it "should send reminders to the From address on the creation mail" do
    mail = Factory :fetched_mail, from: 'sender@g.com'
    r = Factory :reminder, fetched_mail: mail
    r.owner_recipient.should == 'sender@g.com'
  end

  describe 'other_recipients as string or array' do
    let (:r) { Factory :reminder, other_recipients: nil }

    it "should return the other_recipients's or an empty array" do
      r.other_recipients.should == []
    end

    it "should accept an array of other recipients and return an array" do
      r.other_recipients = ['cc@example.com']
      r.save!
      r.reload
      r.other_recipients.should == ['cc@example.com']
    end

    it "should accept an other recipient as a string" do
      r.other_recipients = 'cc@example.com'
      lambda do
        r.save!
      end.should_not raise_exception ActiveRecord::SerializationTypeMismatch
    end

    it "should allow multiple other_recipients to be created with a string" do
      r.other_recipients = 'cc@abc.com, cc1@abc.com'
      lambda do
        r.save!
      end.should_not raise_exception ActiveRecord::SerializationTypeMismatch
    end
  end

  describe "snoozing" do
    let(:reminder) { Factory.build :reminder, fetched_mail: Factory(:fetched_mail, to: ['recipient@g.com'], bcc: ['2h@hound.cc']) }

    it "should generate a snooze token when creating a reminder" do
      reminder.snooze_token.should be_nil
      reminder.save
      reminder.snooze_token.length.should == 8
    end

    it "should not regenerate the snooze token after a reminder has been snoozed" do
      reminder.save
      old_token = reminder.snooze_token
      reminder.snooze_for("2days", old_token)
      reminder.snooze_token.should == old_token
    end

    it "should snooze a reminder for a specified duration" do
      now = Time.zone.now
      reminder.send_at = now
      reminder.snooze_for('2days', reminder.snooze_token)
      reminder.send_at.to_i.should == (now + 2.days).to_i #Ruby times have greater precision
    end

    it "should mark a snoozed reminder as undelivered" do
      reminder.save
      Notifier.send_reminder_email(reminder)
      reminder.delivered?.should == true
      reminder.snooze_for('2months', reminder.snooze_token)
      reminder.delivered?.should == false
    end

    it "should increment the snooze count as the user snoozes" do
      reminder.snooze_count.should == 0 #sanity
      reminder.save
      reminder.snooze_for('2months', reminder.snooze_token)
      reminder.snooze_count.should == 1
    end
  end
end
