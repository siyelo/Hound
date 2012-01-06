class FetchMailWorker
  require 'net/imap'

  def fetch_mail
    imap = Net::IMAP.new('imap.gmail.com', 993, true)
    imap.login('radmeet@siyelo.com', 'i4msoc00l')
    imap.search(["ALL"]).each do |message_id|
      envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
      Reminder.create!(email: envelope.from[0].name, subject: envelope.subject)
    end
  end
end
