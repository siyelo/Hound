class Notifier
  class << self
    def send_confirmation_email(reminder)
      UserMailer.send_confirmation(reminder).deliver
    end

    def send_reminder_email(reminder)
      # this is necessary because we may have more than one worker polling
      unless reminder.delivered?
        (reminder.cc << reminder.email).each do |recipient|
          UserMailer.send_reminder(reminder,recipient).deliver
        end
        reminder.delivered = true
        reminder.save!
      end
    end
    
    def snooze_notification_email(reminder)
      reminder.cc.each do |recipient|
        UserMailer.send_snooze_notification(reminder, recipient).deliver
      end
    end

  end
end

