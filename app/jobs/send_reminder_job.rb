class SendReminderJob
  # This class is responsible for sending
  # the mails once they have been processed
  @queue = :send_queue

  def self.perform(reminder_id)
    reminder = Reminder.find_by_id(reminder_id)
    Notifier.send_reminder_email(reminder)
  end
end
