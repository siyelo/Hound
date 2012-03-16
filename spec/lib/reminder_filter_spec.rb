require 'reminder_filter'

describe ReminderFilter do
  describe "#filter" do
    let(:sortable_scope) { mock(:scope, sorted: [])  }
    let(:reminders) { mock :scope, completed: sortable_scope, upcoming: sortable_scope }

    it "returns upcoming reminders for blank filter" do
      ReminderFilter.new(reminders, nil).filter.should == 'upcoming'
    end

    it "returns upcoming reminders for 'completed' filter" do
      ReminderFilter.new(reminders, 'completed').filter.should == 'completed'
    end

    it "returns upcoming reminders for unknown filter" do
      ReminderFilter.new(reminders, 'thisisntright').filter.should == 'upcoming'
    end

    it ".reminders" do
      ReminderFilter.new(reminders, nil).filtered_reminders.should == []
    end
  end

  def setup_reminders(send_at)
    reminder = mock :reminder, send_at: send_at
    reminders = mock :scope, upcoming: mock(:scope, sorted: [reminder, reminder])
  end

  def setup_reminder(send_at)
    reminder = mock :reminder, send_at: send_at
    reminders = mock :scope, upcoming: mock(:scope, sorted: [reminder])
  end

  describe "#group" do
    context "one reminder" do
      it "groups reminders in next 24 hours in today" do
        reminders = setup_reminder(1.minute.from_now)
        groups   = ReminderFilter.new(reminders).grouped_by_periods
        groups[:today].count.should == 1
      end

      it "groups reminders in 25 - 48 hours in tomorrow" do
        reminders = setup_reminder(1.day.from_now)
        groups   = ReminderFilter.new(reminders).grouped_by_periods
        groups[:tomorrow].count.should == 1
      end

      it "groups reminders in 3-7 days in next week" do
        reminders = setup_reminder 4.days.from_now
        groups   = ReminderFilter.new(reminders).grouped_by_periods
        groups[:next_week].count.should == 1
      end

      it "groups reminders in 8-30 days in next month" do
        reminders = setup_reminder 9.days.from_now
        groups   = ReminderFilter.new(reminders).grouped_by_periods
        groups[:next_month].count.should == 1
      end

      it "groups all reminders further than a month in later" do
        reminders = setup_reminder 6.months.from_now
        groups   = ReminderFilter.new(reminders).grouped_by_periods
        groups[:later].count.should == 1
      end
    end

    context "two reminders" do
      it "groups reminders in next 24 hours in today" do
        user = setup_reminders(1.minute.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:today].count.should == 2
        groups[:tomorrow].count.should == 0
        groups[:next_week].count.should == 0
        groups[:next_month].count.should == 0
        groups[:later].count.should == 0
      end

      it "groups reminders in 25 - 48 hours in tomorrow" do
        user = setup_reminders(1.day.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:today].count.should == 0
        groups[:tomorrow].count.should == 2
        groups[:next_week].count.should == 0
        groups[:next_month].count.should == 0
        groups[:later].count.should == 0
      end

      it "groups reminders in 3-7 days in next week" do
        user = setup_reminders(4.days.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:tomorrow].count.should == 0
        groups[:today].count.should == 0
        groups[:next_week].count.should == 2
        groups[:next_month].count.should == 0
        groups[:later].count.should == 0
      end

      it "groups reminders in 8-30 days in next month" do
        user = setup_reminders(9.days.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:tomorrow].count.should == 0
        groups[:today].count.should == 0
        groups[:next_week].count.should == 0
        groups[:next_month].count.should == 2
        groups[:later].count.should == 0
      end

      it "groups all reminders further than a month in later" do
        user = setup_reminders(5.months.from_now)

        groups = ReminderFilter.new(user).grouped_by_periods
        groups[:tomorrow].count.should == 0
        groups[:today].count.should == 0
        groups[:next_week].count.should == 0
        groups[:next_month].count.should == 0
        groups[:later].count.should == 2
      end
    end
  end
end
