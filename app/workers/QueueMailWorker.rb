class QueueMailWorker
  # This class will poll the database every minute looking
  # for the mails that need to be sent this minute

  @queue = :process_queue

  def self.perform
    time = Time.now.change(sec: 0)
    last_time = time + 59.seconds

    #only select ids
    reminders = Reminder.where("reminder_time >= ? AND reminder_time <= ?",
                  time, last_time)

    reminders.each do |r|
      puts "in processmailworker"
      Resque.enqueue(SendMailWorker, r.id)
    end
  end
end
