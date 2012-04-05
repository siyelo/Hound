#TODO - rename - confusing with Notifier
# call it SnoozeNotificationJob
class NotificationJob
  # This class is to remind users cc'd in an email that
  # the reminder has been snoozed or that a reminder has been changed

  @queue = :notification_queue

  def self.perform(reminder_id)
    Hound::Notifier.send_snooze_notifications(reminder_id)
  end
end
