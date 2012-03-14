require 'spec_helper'

describe Reminder do
  it { should validate_presence_of :send_at }
  it { should validate_presence_of :user }
  it { should validate_presence_of :fetched_mail }
  it { should belong_to :fetched_mail }

  describe "Reminder Mail" do
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
      mail = Factory :fetched_mail, from: ['sender@g.com']
      r = Factory :reminder, fetched_mail: mail
      r.email.should == 'sender@g.com'
    end

    it "should send reminders to the From address on the creation mail" do
      mail = Factory :fetched_mail, to: ['recipient@g.com', '1h@hound.cc'],
        cc: ['recipient2@g.com', '2h@hound.cc']
      r = Factory :reminder, fetched_mail: mail
      r.cc.should == ['recipient@g.com', 'recipient2@g.com']
    end
  end

  describe "bcc" do
    describe "with hound in the bcc field" do
      let(:reminder) { Factory :reminder, is_bcc: true, fetched_mail: Factory(:fetched_mail, to: ['recipient@g.com'], bcc: ['2h@hound.cc']) }

      it "should return whether the hound address that created the reminder was bcc'ed" do
        reminder.is_bcc.should == true
      end

      it "should not cc anyone in the reminder if the Hound address is bcc'ed" do
        reminder.cc.should be_empty
      end

      describe "without hound in the bcc field" do
        let(:reminder) { Factory :reminder, is_bcc: false, fetched_mail: Factory(:fetched_mail, to: ['recipient@g.com'], cc: ['gogoaction@robot.cc']) }
        it "should return whether the hound address that created the reminder was bcc'ed" do
          reminder.is_bcc.should == false
        end

        it "should have email addresses in the cc field" do
          reminder.cc.should_not be_empty
          reminder.cc.size.should == 2
          reminder.cc.should include 'recipient@g.com'
          reminder.cc.should include 'gogoaction@robot.cc'
        end
      end
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
