module RemindersHelper
  def allow_changes(reminder)
    reminder.send_at < DateTime.now && reminder.delivered
  end

  def reminder_subject(reminder)
    reminder.subject.blank? ? '<No Subject>' : reminder.subject
  end
end
