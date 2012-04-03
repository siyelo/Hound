require 'reminder'

class QueueMailJob
  # This class will poll the database every minute looking
  # for the mails that need to be sent this minute

  @queue = :process_queue

  def self.perform
    Queuer.add_all_to_send_queue(Reminder.ready_to_send.with_active_user)
  end
end
