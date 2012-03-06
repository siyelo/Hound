#TODO refactor
class ReminderFilter
  FILTERS = %w(completed)

  LAYERS = {
    today:      0.days,
    tomorrow:   1.day,
    next_week:  1.week,
    next_month: 1.month,
    later:      1000.years
  }

  class << self
    def current_filter(filter)
      FILTERS.include?(filter) ? filter : 'upcoming'
    end

    def filter_reminders(reminders, filter)
      reminders.send(current_filter(filter)).sorted
    end

    def group_reminders(reminders)
      groups = Hash.new{|hash, key| hash[key] = []}
      reminders.each do |r|
        LAYERS.keys.each do |key|
          (groups[key] << r; break) if r.send_at.to_date <= LAYERS[key].from_now.to_date
        end
      end
      groups
    end
  end
end
