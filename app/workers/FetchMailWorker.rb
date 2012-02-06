class FetchMailWorker
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  @queue = :fetch_queue

  def self.perform
    emails = Mail.all
    EmailParser::Dispatcher.dispatch(emails)
  end

end
