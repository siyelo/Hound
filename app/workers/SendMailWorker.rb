class SendMailWorker
  # This class is responsible for sending
  # the mails once they have been processed

  @queue = :send_queue

  def self.perform(mail)
    UserMailer.send_reminder(mail).deliver
  end
end
