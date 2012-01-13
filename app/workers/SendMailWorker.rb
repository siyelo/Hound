class SendMailWorker
  # This class is responsible for sending
  # the mails once they have been processed
  @queue = :send_queue

  def self.perform(reminder_id)
    reminder = Reminder.find_by_id(reminder_id)
    reminder.send_reminder_email
  end
end
