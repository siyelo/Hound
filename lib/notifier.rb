class Notifier
  class << self
    def send_confirmation_email(reminder)
      UserMailer.send_confirmation(reminder).deliver
    end

    def send_reminder_email(reminder)
      reminder_mail = ReminderMail.new(reminder)
      # this is necessary because we may have more than one worker polling
      unless reminder_mail.delivered?
        reminder_mail.all_recipients.each do |recipient|
          UserMailer.send_reminder(reminder,recipient).deliver
        end
        reminder.delivered = true
        reminder.save!
      end
    end

    def snooze_notification_email(reminder)
      #TODO: Send through ReminderMail object
      reminder_mail = ReminderMail.new(reminder)
      reminder_mail.cc.each do |recipient|
        UserMailer.send_snooze_notification(reminder, recipient).deliver
      end
    end

  end
end

