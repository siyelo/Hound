class SendConfirmationJob
  # This class is responsible for sending email reminder confirmations
  @queue = :confirm_queue

  def self.perform(reminder_id)
    reminder = Reminder.find_by_id(reminder_id)
    UserMailer.send_confirmation(reminder).deliver
  end
end
