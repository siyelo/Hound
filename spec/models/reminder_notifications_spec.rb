require 'spec_helper'

#TODO refactor into observers /separate service
describe Reminder do
  before :each do
    ResqueSpec.reset!
  end

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

  it "should not include the snooze links for cc'ed users" do
    reminder = Factory :reminder, subject: "mehpants", cc: "wat@wiggle.com"
    @email = UserMailer.send_reminder(reminder, reminder.cc.first)
    @email.should_not have_body_text('/Snooze for:/')
  end

  it "should properly queue" do
    reminder = Factory :reminder
    SendConfirmationWorker.should have_queue_size_of(1)
    Queuer.add_to_send_queue(reminder)
    SendReminderWorker.should have_queue_size_of(1)
    email = SendReminderWorker.perform(reminder.id)
    reminder.reload.delivered?.should be_true
  end

  it "should append 'RE: ' before the emails subject" do
    reminder = Factory :reminder, subject: "mehpants"
    @email = UserMailer.send_reminder(reminder, reminder.email)
    @email.should have_subject(/Re: mehpants/)
  end
end
