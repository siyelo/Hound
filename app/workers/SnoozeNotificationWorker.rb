class SnoozeNotificationWorker
  # This class is to remind users cc'd in an email that
  # the reminder has been snoozed

  @queue = :snooze_queue

  def self.perform(reminder_id)
    reminder = Reminder.find_by_id(reminder_id)
    reminder.snooze_notification_email
  end
end
