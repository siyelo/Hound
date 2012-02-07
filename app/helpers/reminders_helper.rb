module RemindersHelper

  LAYERS = {
    today:      '0.days.from_now',
    tomorrow:   '1.day.from_now',
    next_week:  '1.week.from_now',
    next_month: '1.month.from_now',
    later:      '1000.years.from_now'
  }

  FILTERS = %w(completed due_today undelivered)

  def group_reminders(reminders)
    groups = Hash.new{|hash, key| hash[key] = Array.new}
    reminders.each do |r|
      LAYERS.keys.each do |key|
        (groups[key] << r; break) if r.reminder_time.to_date <= eval(LAYERS[key]).to_date
      end
    end
    return groups
  end

  def filter_reminders(filter)
    if FILTERS.include?(filter)
      current_user.reminders.send(filter).sorted
    else
      current_user.reminders.upcoming.sorted
    end
  end

  def current_filter
    FILTERS.include?(params[:filter]) ? params[:filter] : 'upcoming'
  end

  def allow_changes(reminder)
    return true if reminder.reminder_time < DateTime.now && reminder.delivered
  end
end
