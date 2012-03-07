class Queuer
  class << self

    def add_all_to_send_queue(reminders)
      reminders ||= []
      reminders.each do |r|
        self.add_to_send_queue(r)
      end
    end

    def add_to_send_queue(reminder)
      Resque.enqueue(SendReminderWorker, reminder.id)
    end

    # sends emails to the people cc'd on an email when the main one is snoozed
    def add_to_snooze_to_notification_queue(reminder)
      unless reminder.cc.empty?
        Resque.enqueue(NotificationWorker, reminder.id, :snooze_notification_email)
      end
    end

    def queue_error_notification(email)
      Resque.enqueue(ErrorNotificationWorker, email)
    end
  end
end
