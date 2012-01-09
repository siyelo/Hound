class ProcessMailWorker
  # Here we will have the mail processing
  # This will be responsible for checking
  # whether a user has an account or enough
  # email credits to send an email

  @queue = :process_queue

  def self.perform(reminder_id)
    mail = Reminder.find_by_id(reminder_id)
    Resque.enqueue(SendMailWorker, mail)
  end
end
