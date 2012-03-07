class ReminderFilter
  AVAILABLE_FILTERS = %w(completed)
  DEFAULT_FILTER    = 'upcoming'
  PERIODS           = {
    today:      0.days,
    tomorrow:   1.day,
    next_week:  1.week,
    next_month: 1.month,
    later:      1000.years
  }

  attr_reader :filter, :user

  def initialize(user, filter = DEFAULT_FILTER)
    @user   = user
    @filter = AVAILABLE_FILTERS.include?(filter) ? filter : DEFAULT_FILTER
  end

  def grouped_by_periods
    groups = Hash.new{|hash, key| hash[key] = []}

    filtered_reminders.each do |reminder|
      period_name = find_period_name(reminder)
      groups[period_name] << reminder
    end

     groups
  end

  def reminders
    user.reminders
  end

  def filtered_reminders
    user.reminders.send(filter).sorted
  end

  private

    def find_period_name(reminder)
      period = PERIODS.detect do |period_name, period|
        reminder.send_at.to_date <= period.from_now.to_date
      end

      period[0]
    end
end
