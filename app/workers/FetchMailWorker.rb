class FetchMailWorker
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  require 'net/imap'

  @queue = :fetch_queue

  def self.perform
    imap = Net::IMAP.new('imap.gmail.com', 993, true)
    imap.login('radmeet@siyelo.com', 'i4msoc00l')
    imap.examine('INBOX')
    imap.search(["ALL"]).each do |message_id|
      envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
      reminder = Reminder.create!(email: envelope.from[0].name, subject: envelope.subject)
      Resque.enqueue(ProcessMailWorker, reminder.id)
    end
  end
end
