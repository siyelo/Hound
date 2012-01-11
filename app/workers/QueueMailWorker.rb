class QueueMailWorker
  # This class will poll the database every minute looking
  # for the mails that need to be sent this minute

  @queue = :process_queue

  def self.perform
    reminders = Reminder.fetch_reminders

    reminders.select{ |rem| rem.user.active? }.each do |r|
      puts "in processmailworker"
      r.add_to_send_queue
    end
  end
end
