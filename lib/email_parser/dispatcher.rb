module EmailParser
  class Dispatcher
    def self.dispatch(emails)
      emails.each do |e|
        parent_message = MessageThread.find_by_message_id(e.in_reply_to)
        message = MessageThread.create!(message_id: e.message_id, parent: parent_message)

        to_us = self.extract_to_us(e, parent_message)

        to_us.each do |to|
          send_at = self.parse_email(to, e)
          r = Reminder.create!(email: e.from.first.to_s, subject: e.subject,
                               body: self.extract_html_or_text(e),
                               send_at: send_at,
                               user: User.find_or_invite(e),
                               sent_to: to, cc: self.extract_reminder_cc(e, to, to_us),
                               message_thread: message) if send_at
        end
      end
    end

    private

    class << self
      ### Factory for dispatching emails to the correct parser
      def parse_email(to, email = nil)
        # local part is the first part of the email
        # we use this to determine when the email should be returned
        local_part = to.split('@')[0] || to

        send_at = nil

        send_at = if local_part.match /(?!months)[a-z]{6,10}/
                          EmailParser::AdverbParser.new(to).send_at
                        elsif local_part.match /\d+[a-z]+/
                          EmailParser::IncrementalTime.new(to).send_at
                        end


        send_at ? send_at : self.calendar_date_parse(email, local_part)
      end

      #refactor me
      def calendar_date_parse(email, local_part)
        begin
          DateTime.parse(local_part).change(hour: 8)
        rescue ArgumentError
          Resque.enqueue(ErrorNotificationWorker, email) if email
          nil
        end
      end


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
