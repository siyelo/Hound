require 'spec_helper'

describe ReminderPresenter do
    it "should return upcoming for blank or unknown filters" do
      ReminderPresenter.new([],'completed').filter.should == 'completed'
      ReminderPresenter.new([],'thisisntright').filter.should == 'upcoming'
      ReminderPresenter.new([],nil).filter.should == 'upcoming'
    end
    
    it "should group reminders in next 24 hours in today" do
      send_at = DateTime.parse_email('1m@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderPresenter.new(reminder.user.reminders).groups
      groups[:today].count.should == 1
    end

    it "should group reminders in 25 - 48 hours in tomorrow" do
      send_at = DateTime.parse_email('tomorrow@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderPresenter.new(reminder.user.reminders).groups
      groups[:tomorrow].count.should == 1
    end

    it "should group reminders in 3-7 days in next week" do
      send_at = DateTime.parse_email('4d@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderPresenter.new(reminder.user.reminders).groups
      groups[:next_week].count.should == 1
    end

    it "should group reminders in 8-30 days in next month" do
      send_at = DateTime.parse_email('3weeks@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderPresenter.new(reminder.user.reminders).groups 
      groups[:next_month].count.should == 1
    end

    it "should group all reminders further than a month in later" do
      send_at = DateTime.parse_email('5months@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderPresenter.new(reminder.user.reminders).groups
      groups[:later].count.should == 1
    end

    it "should return reminders with the filter applied" do
      reminder1 = Factory :reminder, send_at: DateTime.parse_email('tomorrow@hound.cc')
      reminder2 = Factory :reminder, send_at: DateTime.parse_email('3weeks@hound.cc'), user: reminder1.user
      presenter = ReminderPresenter.new(reminder1.user.reminders, 'upcoming')
      presenter.filtered_reminders.should == [reminder1, reminder2]
    end

end
