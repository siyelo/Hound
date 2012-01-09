class FetchMailWorker
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  #require 'net/imap'

  @queue = :fetch_queue

  def self.perform
    emails = Mail.all

    emails.each do |e|
      reminder = Reminder.create!(email: e.from, subject: e.subject, body: e.body.to_s)
      Resque.enqueue(ProcessMailWorker, reminder.id)
    end
  end
end
