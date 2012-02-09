class ReminderFilter
  FILTERS = %w(completed due_today undelivered)

  LAYERS = {
    today:      0.days.from_now,
    tomorrow:   1.day.from_now,
    next_week:  1.week.from_now,
    next_month: 1.month.from_now,
    later:      1000.years.from_now
  }

  def self.current_filter(filter)
    FILTERS.include?(filter) ? filter : 'upcoming'
  end

  def self.filter_reminders(reminders, filter)
    reminders.send(self.current_filter(filter)).sorted
  end

  def self.group_reminders(reminders)
    groups = Hash.new{|hash, key| hash[key] = []}
    reminders.each do |r|
      LAYERS.keys.each do |key|
        (groups[key] << r; break) if r.reminder_time.to_date <= LAYERS[key].to_date
      end
    end
    groups
  end

end
