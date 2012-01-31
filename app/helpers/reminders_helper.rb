module RemindersHelper

  LAYERS = {
    today:      '0.days.from_now',
    tomorrow:   '1.day.from_now',
    next_week:  '1.week.from_now',
    next_month: '1.month.from_now',
    later:      '1000.years.from_now'
  }

  def group_reminders(reminders)
    groups = Hash.new{|hash, key| hash[key] = Array.new}
    reminders.each do |r|
      LAYERS.keys.each do |key|
        (groups[key] << r; break) if r.reminder_time.to_date <= eval(LAYERS[key]).to_date
      end
    end
    return groups
  end
end
