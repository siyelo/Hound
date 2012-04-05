class SendReminderJob
  # This class is responsible for sending
  # the mails once they have been processed
  @queue = :send_queue

  def self.perform(reminder_id)
    Hound::Notifier.send_reminders(reminder_id)
  end
end
