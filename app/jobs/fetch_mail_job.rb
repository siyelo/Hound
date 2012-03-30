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
    @imap.login(USERNAME, PASSWORD)
    @imap.select(FOLDER)
  end

  def save_mail(mail)
    service = ReminderCreationService.new
    service.create!(mail)
  end

  def fetch_messages
    imap.search(["ALL"]).each do |message_id|
      fetched_data = imap.fetch(message_id, ['RFC822'])[0]
      mail = Mail.new(fetched_data.attr['RFC822'])

      save_mail(mail)

      imap.store(message_id, "+FLAGS", [:Deleted])
    end
  end

  def start
    loop do
      wait_for_messages
    end
  end

  def wait_for_messages
    imap.idle do |resp|
      if resp.kind_of?(Net::IMAP::UntaggedResponse) && resp.name == "EXISTS"
        imap.idle_done
      end
    end

    fetch_messages
  end
end
