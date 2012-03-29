class Queuer
  class << self
    def add_all_to_send_queue(reminders)
      reminders ||= []
      reminders.each do |r|
        Resque.enqueue(SendReminderJob, r.id)
      end
    end
  end
end
