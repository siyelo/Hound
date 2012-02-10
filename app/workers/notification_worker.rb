class NotificationWorker
  # This class is to remind users cc'd in an email that
  # the reminder has been snoozed or that a reminder has been changed

  @queue = :notification_queue

  def self.perform(reminder_id, type)
    reminder = Reminder.find_by_id(reminder_id)
    reminder.send(type)
  end
end
