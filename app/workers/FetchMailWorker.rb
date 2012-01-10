class FetchMailWorker
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  @queue = :fetch_queue

end
