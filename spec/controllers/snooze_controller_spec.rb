require 'spec_helper'

describe SnoozeController do

  describe 'snoozing' do
    before :each do
      ResqueSpec.reset!
      @reminder = FactoryGirl.create :reminder
    end

    it "should inform the cc'd users that the reminder has been snoozed" do
      method = :send_snooze_notifications
      @reminder.other_recipients = ["pimpchains@rus.com", "tapped@datass.yo"]; @reminder.save
      get :show, id: @reminder.id
      NotificationJob.should have_queue_size_of(1)
      response.should render_template('informed_of_snooze')
      NotificationJob.perform(@reminder.id)
      unread_emails_for('pimpchains@rus.com').size.should >= parse_email_count(1)
      unread_emails_for('tapped@datass.yo').size.should >= parse_email_count(1)
    end

    it "should not allow a snooze if the token is invalid" do
      get :edit, id: @reminder.id
      response.should render_template('snooze_failed')
    end

    it "should not allow a snooze without duration" do
      get :edit, id: @reminder.id, token: @reminder.snooze_token
      response.should render_template('snooze_failed')
    end

    it "should show the new reminder time after successfully snoozing" do
      old_time = @reminder.send_at
      get :edit, id: @reminder.id, duration: '2days', token: @reminder.snooze_token
      response.should render_template('snooze_reminder')
    end
  end
end
