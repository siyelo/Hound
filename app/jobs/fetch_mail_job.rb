require 'reminder_creation_service'
require 'net/imap'

class FetchMailJob
  SERVER   = 'imap.gmail.com'
  USERNAME = ENV['HOUND_USERNAME']
  PASSWORD = ENV['HOUND_PASSWORD']
  FOLDER   = 'INBOX'

  attr_accessor :imap

  def initialize
    @imap = Net::IMAP.new SERVER, :ssl => true
    @imap.login USERNAME, PASSWORD
    @imap.select(FOLDER)
  end

  def save_mail(mail)
    service = ReminderCreationService.new
    service.create!(mail)
  end

  def fetch_messages
    imap.search(["ALL"]).each do |message_id|
      puts message_id
      fetchdata = imap.fetch(message_id, ['RFC822'])[0]
      mail = Mail.new(fetchdata.attr['RFC822'])

      save_mail(mail)

      puts "deleting #{message_id}"
      imap.store(message_id, "+FLAGS", [:Deleted])
    end
  end

  def start
    puts 'Starting engines...'
    loop do
      puts 'waiting...'
      imap.idle do |resp|
        if resp.kind_of?(Net::IMAP::UntaggedResponse) and resp.name == "EXISTS"
          puts "Mailbox now has #{resp.data} messages"
          imap.idle_done
        end
      end

      fetch_messages
    end
  end
end
