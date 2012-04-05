# Service for sending all mails.
#
# Contains much of the business logic for outgoing mails
# along with a few wrappers for the simpler UserMailer objects, mostly
# for consistency's sake, but also to make the *Jobs simpler too
#
module Hound
  class Notifier
    class << self
      def send_reminders(reminder_id)
        reminder = Reminder.find_by_id(reminder_id)
        # this is necessary because we may have more than one worker polling
        unless reminder.delivered?
          owner =  reminder.fetched_mail.from
          reminder.all_recipients.each do |recipient|
            if owner == recipient
              UserMailer.reminder(reminder, recipient).deliver
            else
              UserMailer.recipient_reminder(reminder, recipient).deliver
            end
          end
          reminder.delivered = true
          reminder.save!
        end
      end

      def send_snooze_notifications(reminder_id)
        reminder = Reminder.find_by_id(reminder_id)
        reminder.other_recipients.each do |recipient|
          UserMailer.snooze(reminder, recipient).deliver
        end
      end

      def send_confirmation(reminder_id)
        reminder = Reminder.find_by_id(reminder_id)
        UserMailer.confirmation(reminder).deliver
      end

      def send_error_notification(fetched_mail_id)
        fetched_mail = FetchedMail.find_by_id(fetched_mail_id)
        UserMailer.error(fetched_mail).deliver
      end
    end
  end
end
