require 'spec_helper'

describe SnoozeController do

  describe 'snoozing' do
    before :each do
      @reminder = Factory :reminder
    end

    it "should not allow a snooze if the token is invalid" do
      put :update, id: @reminder.id
      response.should render_template('snooze_failed')
    end

    it "should not allow a snooze without duration" do
      get :update, id: @reminder.id, token: @reminder.snooze_token
      response.should render_template('snooze_failed')
    end

    it "should show the new reminder time after successfully snoozing" do
      old_time = @reminder.reminder_time
      get :update, id: @reminder.id, duration: '2days', token: @reminder.snooze_token
      response.should render_template('snooze_reminder')
    end
  end
end
