class SendConfirmationWorker
  # This class is responsible for sending email reminder confirmations
  @queue = :confirm_queue

  def self.perform(reminder_id)
    reminder = Reminder.find_by_id(reminder_id)
    reminder.send_confirmation_email
  end
end
