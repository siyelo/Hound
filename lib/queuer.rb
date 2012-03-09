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

    # when a reminder is changed it adds an email to the recipients to the notification
    # queue to inform them of this change
    def queue_change_notification(reminder)
      if (reminder.body_changed? || reminder.send_at_changed?) && !reminder.cc.empty?
        Resque.enqueue(NotificationWorker, reminder.id, :inform_other_recipients)
      end
    end

    def queue_confirmation_email(reminder)
      Resque.enqueue(SendConfirmationWorker, reminder.id) if reminder.user.confirmation_email?
    end

    def queue_error_notification(email)
      Resque.enqueue(ErrorNotificationWorker, email)
    end
  end
end
