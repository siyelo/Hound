require 'spec_helper'

describe Notifier do
  it "should mark reminder as sent", type: 'integration' do 
    reminder = Factory :reminder
    Notifier.send_reminder_email(reminder)
    reminder.reload.delivered?.should be_true
  end
end
