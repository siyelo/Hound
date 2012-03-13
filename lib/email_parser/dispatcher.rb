module EmailParser
  class Dispatcher
    def self.dispatch(emails)
      @service = ReminderCreationService.new()

      emails.each do |e|
        parent_message = MessageThread.find_by_message_id(e.in_reply_to)
        message = MessageThread.create!(message_id: e.message_id, parent: parent_message)

        to_us = self.extract_to_us(e, parent_message)

        to_us.each do |to|
          send_at = @service.parse_or_notify(to, e)
          r = Reminder.create!(email: e.from.first.to_s, subject: e.subject,
                               body: EmailBodyParser.extract_html_or_text_from_body(e),
                               send_at: send_at,
                               user: User.find_or_invite!(e),
                               sent_to: to, cc: self.extract_reminder_cc(e, to, to_us),
                               message_thread: message) if send_at
        end
      end
    end

    private

    class << self

      def extract_to_us(email, parent_message)
        to_us = self.all_addresses(email).select{ |t| t.include?('@hound.cc') }
        to_us -= parent_message.hound_recipients if parent_message

        to_us
      end

      def extract_not_to_us(email, to_us)
        self.all_addresses(email) - to_us
      end

      def extract_reminder_cc(email, to, hound_recipients)
        if email.bcc.include?(to)
          cc = []
        else
          self.extract_not_to_us(email, hound_recipients)
        end
      end

      def all_addresses(email)
        email.cc ||= []
        email.bcc ||= []
        email.to + email.cc + email.bcc
      end

    end
  end
end
