require 'net/imap'
require 'singleton'
require 'logger'

class FetchMailJob
  include Singleton

  SERVER   = 'imap.gmail.com'
  USERNAME = ENV['HOUND_USERNAME']
  PASSWORD = ENV['HOUND_PASSWORD']
  FOLDER   = 'INBOX'


  attr_accessor :imap, :logger

  def initialize
    register_signals

    @imap = Net::IMAP.new SERVER, :ssl => true
    @imap.login(USERNAME, PASSWORD)
    @imap.select(FOLDER)

    @logger = Logger.new(File.join(Rails.root, 'log', 'fetch_mail_job.log'))
  end

  def save_mail(mail)
    service = ReminderCreationService.new
    service.create!(mail)
  end

  def fetch_messages
    imap.search(["NOT", "SEEN"]).each do |message_id|
      fetched_data = imap.fetch(message_id, ['RFC822'])[0]
      mail = Mail.new(fetched_data.attr['RFC822'])

      save_mail(mail)

      imap.store(message_id, "+FLAGS", [:Seen])

      logger.info "#{Time.now} Saved mail with message id: #{mail.message_id}."
    end
  end

  def start
    logger.info "#{Time.now} FetchMailJob started."

    fetch_messages

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

  def stop
    logger.info "#{Time.now} FetchMailJob stopped."
    imap.idle_done
    exit
  end

  private
    def register_signals
      Signal.trap("SIGINT") do
        FetchMailJob.instance.stop
      end

      Signal.trap("SIGTERM") do
        FetchMailJob.instance.stop
      end
    end
end
