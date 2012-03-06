module RemindersHelper
  def allow_changes(reminder)
    reminder.send_at < DateTime.now && reminder.delivered
  end
end
