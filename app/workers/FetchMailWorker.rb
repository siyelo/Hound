class FetchMailWorker
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  @queue = :fetch_queue

  def self.perform
    puts "in fetchmailworker"
    emails = Mail.all

    emails.each do |e|
      reminder = Reminder.create!(email: e.from, subject: e.subject,
                  body: e.body.to_s, :reminder_time => Time.now)
      #Resque.enqueue(QueueMailWorker, reminder.id)
    end
  end
end
