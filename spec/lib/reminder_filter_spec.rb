require 'spec_helper'

describe ReminderFilter do
  describe "groupings" do
    it "should group reminders in next 24 hours in today" do
      send_at = EmailParser::Dispatcher.parse_email('0m@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderFilter.group_reminders([reminder])
      groups[:today].count.should == 1
    end

    it "should group reminders in 25 - 48 hours in tomorrow" do
      send_at = EmailParser::Dispatcher.parse_email('tomorrow@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderFilter.group_reminders([reminder])
      groups[:tomorrow].count.should == 1
    end

    it "should group reminders in 3-7 days in next week" do
      send_at = EmailParser::Dispatcher.parse_email('4d@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderFilter.group_reminders([reminder])
      groups[:next_week].count.should == 1
    end

    it "should group reminders in 8-30 days in next month" do
      send_at = EmailParser::Dispatcher.parse_email('3weeks@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderFilter.group_reminders([reminder])
      groups[:next_month].count.should == 1
    end

    it "should group all reminders further than a month in later" do
      send_at = EmailParser::Dispatcher.parse_email('5months@hound.cc')
      reminder = Factory :reminder, send_at: send_at
      groups = ReminderFilter.group_reminders([reminder])
      groups[:later].count.should == 1
    end
  end

  describe 'filters' do
    it "should return upcoming for blank or unknown filters" do
      ReminderFilter.current_filter('completed').should == 'completed'
      ReminderFilter.current_filter('thisisntright').should == 'upcoming'
      ReminderFilter.current_filter(nil).should == 'upcoming'
    end
  end
end
