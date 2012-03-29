require 'spec_helper'

describe Notifier do
  context '#send_reminder_email'
  it "should mark reminder as sent", type: 'integration' do
    reminder = Factory :reminder
    Notifier.send_reminder_email(reminder)
    reminder.reload.delivered?.should be_true
  end

  it "should send a reminder to a person cc'ed on original mail" do
    reminder = Factory :reminder, other_recipients: ['pimpcc@juice.com']
    Notifier.send_reminder_email(reminder)
    unread_emails_for('pimpcc@juice.com').size.should >= parse_email_count(1)
  end

  it "should send a reminder to the person who created original mail" do
    reminder = Factory :reminder, fetched_mail: Factory(:fetched_mail, from:'pimpto@juice.com')
    Notifier.send_reminder_email(reminder)
    unread_emails_for('pimpto@juice.com').size.should >= parse_email_count(1)
  end
end
