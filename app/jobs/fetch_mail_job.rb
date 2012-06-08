require 'net/imap'
require 'singleton'
require 'logger'

class FetchMailJob
  include Singleton

  SERVER   = 'imap.gmail.com'
  USERNAME = ENV['HOUND_EMAIL_USERNAME']
  PASSWORD = ENV['HOUND_EMAIL_PASSWORD']
  FOLDER   = 'INBOX'

  attr_accessor :imap, :logger

  def initialize
    @imap = Net::IMAP.new SERVER, :ssl => true
    @imap.login(USERNAME, PASSWORD)
    @imap.select(FOLDER)

    @logger = Logger.new(File.join(Rails.root, 'log', 'fetch_mail_job.log'))

    register_signals
  end

  def start
    logger.info "#{Time.now} FetchMailJob started"

    fetch_messages

    loop do
      wait_for_messages
      fetch_messages
    end
  end

  def stop
    logger.info "#{Time.now} FetchMailJob stopped"
    imap.disconnect
    exit
  end

  def save_mail(mail)
    service = ReminderCreationService.new
    service.create!(mail)
  end

  def fetch_messages
    tries = 0
    begin
      tries += 1
      imap.uid_search(["ALL"]).each do |message_id|
        fetched_data = imap.uid_fetch(message_id, ['RFC822'])[0]
        mail = Mail.new(fetched_data.attr['RFC822'])

        save_mail(mail)

        imap.uid_store(message_id, "+FLAGS", [:Deleted])

        logger.info "#{Time.now} Mail saved UID: #{message_id}"
      end
    rescue IOError, EOFError, Errno::EPIPE => e
      Airbrake.notify(e)
      tries == 5 ? raise(e) : retry
    end
  end

  def wait_for_messages
    imap.idle do |resp|
      if resp.kind_of?(Net::IMAP::UntaggedResponse) && resp.name == "EXISTS"
        imap.idle_done
      end
    end
  rescue Net::IMAP::Error => e
    Airbrake.notify(e)
    false
    #do nothing
  end

  private
    def register_signals
      # signal when interruping the process from terminal (CTRL + c)
      Signal.trap("SIGINT") do
        FetchMailJob.instance.stop
      end

      # default signal sent to a process by the kill or killall commands
      Signal.trap("SIGTERM") do
        FetchMailJob.instance.stop
      end
    end
end
