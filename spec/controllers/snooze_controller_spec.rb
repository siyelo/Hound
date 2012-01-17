require 'spec_helper'

describe SnoozeController do

  describe 'snoozing' do
    before :each do
      @reminder = Factory :reminder
    end

    it "should map snooze_reminder(1) to /reminders/1/snooze" do
      snooze_reminder_path(1).should == '/reminders/1/snooze'
    end

    it "should not allow a snooze if the token is invalid" do
      get :snooze_reminder, id: @reminder.id
      response.should render_template('snooze_failed')
    end

    it "should not allow a snooze without duration" do
      get :snooze_reminder, id: @reminder.id, token: @reminder.snooze_token
      response.should render_template('snooze_failed')
    end

    it "should show the new reminder time after successfully snoozing" do
      old_time = @reminder.reminder_time
      get :snooze_reminder, id: @reminder.id, duration: '2days', token: @reminder.snooze_token
      response.should render_template('snooze_reminder')
    end
  end
end
