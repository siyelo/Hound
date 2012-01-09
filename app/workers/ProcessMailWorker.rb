class ProcessMailWorker
  # Here we will have the mail processing
  # This will be responsible for checking
  # whether a user has an account or enough
  # email credits to send an email

  @queue = :process_queue
  def self.perform(mail)
    Resque.enqueue(SendMailWorker, mail)
  end
end
