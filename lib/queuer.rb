class Queuer
  class << self
    def add_all_to_send_queue(reminders)
      reminders ||= []
      reminders.each do |r|
        Resque.enqueue(SendReminderWorker, r.id)
      end
    end

    # sends emails to the people cc'd on an email when the main one is snoozed
    def add_to_snooze_to_notification_queue(reminder)
      unless reminder.cc.empty? && reminder.fetched_mail.cc.empty?
        Resque.enqueue(NotificationWorker, reminder.id)
      end
    end
  end
end
