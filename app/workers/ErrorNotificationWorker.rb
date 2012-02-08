class ErrorNotificationWorker
  # This class is to remind users cc'd in an email that
  # the reminder has been snoozed or that a reminder has been changed

  @queue = :error_queue

  def self.perform(email)
    UserMailer.send_error_notification(email).deliver
  end
end
