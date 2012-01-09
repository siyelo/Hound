class SendMailWorker
  # This class is responsible for sending
  # the mails once they have been processed

  @queue = :send_queue

  def self.perform(reminder_id)
    mail = Reminder.find_by_id(reminder_id)
    UserMailer.send_reminder(mail).deliver
  end
end
