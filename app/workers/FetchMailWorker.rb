class FetchMailWorker
  require 'net/imap'

  def fetch_mail
    imap = Net::IMAP.new('imap.gmail.com', 993, true)
    imap.login('rad.meet@siyelo.com', 'i4msoc00l')
    imap.search(["SUBJECT", "tokai", "NOT", "NEW"]).each do |message_id|
      envelope = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
      puts "#{envelope.from[0].name}: \t#{envelope.subject}"
      Reminder.create!(email: envelope.from[0].name, subject: envelope.subject)
    end
  end
end
