require 'hound'

class SendConfirmationJob
  # This class is responsible for sending email reminder confirmations
  @queue = :confirm_queue

  def self.perform(reminder_id)
    Hound::Notifier.send_confirmation(reminder_id)
  end
end
