module RemindersHelper
  def allow_changes(reminder)
    reminder.reminder_time < DateTime.now && reminder.delivered
  end
end
