class ReminderPresenter
  @@available_filters = %w(completed)
  @@default_filter = 'upcoming'

  @@layers = {
    today:      0.days,
    tomorrow:   1.day,
    next_week:  1.week,
    next_month: 1.month,
    later:      1000.years
  }

  attr_reader :filter, :reminders

  def initialize(reminders, filter = @@default_filter)
    @reminders = reminders
    @filter =  @@available_filters.include?(filter) ? filter : @@default_filter
  end

  def groups
    @groups ||= group_reminders
  end

  def filtered_reminders
    @filtered_reminders ||= @reminders.send(@filter).sorted
  end

  private

  # Before grouping, we always apply the filter to the reminders first
  def group_reminders
    groups ||= Hash.new{|hash, key| hash[key] = []}
    filtered_reminders.each do |r|
      @@layers.keys.each do |key|
        (groups[key] << r; break) if r.send_at.to_date <= @@layers[key].from_now.to_date
      end
    end
    groups
  end
end
