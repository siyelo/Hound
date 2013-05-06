require 'spec_helper'
require 'hound/services/notifier'

describe Hound::Notifier do
  let (:orig_mail) { FactoryGirl.create :fetched_mail, body: 'body', from: 'sender@a.com',
    :subject => 'orig subject', cc: ['cc@a.com', 'cc@b.com'] }
  let(:reminder) { FactoryGirl.create :reminder, fetched_mail: orig_mail, user:orig_mail.user,
    created_at: '2012-01-01', other_recipients: orig_mail.cc }

  describe'#send_reminders' do
    it "should mark reminder as sent", type: 'integration' do
      Hound::Notifier.send_reminders(reminder)
      reminder.reload.delivered?.should be_true
    end

    it "should send a reminder to a person cc'ed on original mail" do
      Hound::Notifier.send_reminders(reminder)
      unread_emails_for('cc@a.com').size.should >= parse_email_count(1)
    end

    it "should send a reminder to the person who created original mail" do
      Hound::Notifier.send_reminders(reminder)
      unread_emails_for('sender@a.com').size.should >= parse_email_count(1)
    end
  end

  describe "#send_snooze_notifications" do
    it "send snoozes to all recipients", type: 'integration' do
      Hound::Notifier.send_snooze_notifications(reminder)
      unread_emails_for('cc@a.com').size.should >= parse_email_count(1)
      unread_emails_for('cc@b.com').size.should >= parse_email_count(1)
    end
  end

  describe "#send_confirmation" do
    it "sends one confirmation, to the sender" do
      Hound::Notifier.send_confirmation(reminder.id)
      unread_emails_for('sender@a.com').size.should >= parse_email_count(1)
    end
  end

  describe "#send_error_notification" do
    it "sends one error to the sender" do
      Hound::Notifier.send_error_notification(orig_mail.id)
      unread_emails_for('sender@a.com').size.should >= parse_email_count(1)
    end
  end
end
