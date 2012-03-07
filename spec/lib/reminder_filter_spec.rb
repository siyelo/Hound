require 'spec_helper'

describe ReminderFilter do

  describe "#filter" do
    let(:user) { stub("user") }

    it "returns upcoming reminders for blank filter" do
      ReminderFilter.new(user, nil).filter.should == 'upcoming'
    end

    it "returns upcoming reminders for 'completed' filter" do
      ReminderFilter.new(user, 'completed').filter.should == 'completed'
    end

    it "returns upcoming reminders for unknown filter" do
      ReminderFilter.new(user, 'thisisntright').filter.should == 'upcoming'
    end
  end

  describe "#group" do
    context "one reminder" do
      it "groups reminders in next 24 hours in today" do
        send_at  = 1.minute.from_now
        reminder = Factory :reminder, send_at: send_at
        groups   = ReminderFilter.new(reminder.user).grouped_by_periods
        groups[:today].count.should == 1
      end

      it "groups reminders in 25 - 48 hours in tomorrow" do
        send_at  = 1.day.from_now
        reminder = Factory :reminder, send_at: send_at
        groups   = ReminderFilter.new(reminder.user).grouped_by_periods
        groups[:tomorrow].count.should == 1
      end

      it "groups reminders in 3-7 days in next week" do
        send_at  = 4.days.from_now
        reminder = Factory :reminder, send_at: send_at
        groups   = ReminderFilter.new(reminder.user).grouped_by_periods
        groups[:next_week].count.should == 1
      end

      it "groups reminders in 8-30 days in next month" do
        send_at  = 9.days.from_now
        reminder = Factory :reminder, send_at: send_at
        groups   = ReminderFilter.new(reminder.user).grouped_by_periods
        groups[:next_month].count.should == 1
      end

      it "groups all reminders further than a month in later" do
        send_at  = 5.months.from_now
        reminder = Factory :reminder, send_at: send_at
        groups   = ReminderFilter.new(reminder.user).grouped_by_periods
        groups[:later].count.should == 1
      end
    end

    context "two reminders" do
      def setup_user_and_reminders(send_at)
        Factory(:user,
                 fetched_mails: [
                   Factory(:fetched_mail,
                           reminders: [Factory(:reminder,
                                                send_at: send_at)]),
                   Factory(:fetched_mail,
                           reminders: [Factory(:reminder,
                                                send_at: send_at)])])
      end

      it "groups reminders in next 24 hours in today" do
        user = setup_user_and_reminders(1.minute.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:today].count.should == 2
        groups[:tomorrow].count.should == 0
        groups[:next_week].count.should == 0
        groups[:next_month].count.should == 0
        groups[:later].count.should == 0
      end

      it "groups reminders in 25 - 48 hours in tomorrow" do
        user = setup_user_and_reminders(1.day.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:today].count.should == 0
        groups[:tomorrow].count.should == 2
        groups[:next_week].count.should == 0
        groups[:next_month].count.should == 0
        groups[:later].count.should == 0
      end

      it "groups reminders in 3-7 days in next week" do
        user = setup_user_and_reminders(4.days.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:tomorrow].count.should == 0
        groups[:today].count.should == 0
        groups[:next_week].count.should == 2
        groups[:next_month].count.should == 0
        groups[:later].count.should == 0
      end

      it "groups reminders in 8-30 days in next month" do
        user = setup_user_and_reminders(9.days.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:tomorrow].count.should == 0
        groups[:today].count.should == 0
        groups[:next_week].count.should == 0
        groups[:next_month].count.should == 2
        groups[:later].count.should == 0
      end

      it "groups all reminders further than a month in later" do
        user = setup_user_and_reminders(5.months.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:tomorrow].count.should == 0
        groups[:today].count.should == 0
        groups[:next_week].count.should == 0
        groups[:next_month].count.should == 0
        groups[:later].count.should == 2
      end
    end
  end

  it "should return reminders with the filter applied" do
    user         = Factory :user
    fetched_mail = Factory :fetched_mail, user: user
    reminder1    = Factory :reminder, send_at: 1.day.from_now,
                            fetched_mail: fetched_mail
    reminder2    = Factory :reminder, send_at: 3.weeks.from_now,
                            fetched_mail: fetched_mail

    filter = ReminderFilter.new(user, 'upcoming')
    filter.filtered_reminders.should == [reminder1, reminder2]
  end
end
