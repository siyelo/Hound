require 'spec_helper'

describe ScopesReminders do
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
end
