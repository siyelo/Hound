require 'reminder_creation_service'

class FetchMailJob
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  @queue = :fetch_queue

  def self.perform
    service = ReminderCreationService.new
    service.fetch_all_mails
  end
end
