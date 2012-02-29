class QueueMailWorker
  # This class will poll the database every minute looking
  # for the mails that need to be sent this minute

  @queue = :process_queue

  def self.perform
    reminders = Reminder.fetch_reminders

    reminders.select{ |rem| rem.user.active? }.each do |r|
      Queuer.add_to_send_queue(r)
    end
  end
end
