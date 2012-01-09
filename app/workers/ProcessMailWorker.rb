class ProcessMailWorker
  # Here we will have the mail processing
  # This will be responsible for checking
  # whether a user has an account or enough
  # email credits to send an email

  @queue = :process_queue

  def self.perform(reminder_id)
    puts "in processmailworker"
    Resque.enqueue(SendMailWorker, reminder_id)
    #Resque.enqueue_at(1.minute.from_now, SendMailWorker, reminder_id)
  end
end
