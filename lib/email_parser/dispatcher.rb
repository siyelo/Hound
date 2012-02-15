module EmailParser
  class Dispatcher
    def self.dispatch(emails)
      emails.each do |e|
        parent_message = MessageThread.find_by_message_id(e.in_reply_to)
        message = MessageThread.create!(message_id: e.message_id, parent: parent_message)

        to_us = self.extract_to_us(e, parent_message)
        not_to_us = self.extract_not_to_us(e, to_us)

        to_us.each do |to|
          reminder_time = self.parse_email(to, e)
          r = Reminder.create!(email: e.from.first.to_s, subject: e.subject,
                               body: self.extract_html_or_text(e),
                               reminder_time: reminder_time,
                               user: User.find_or_invite(e),
                               sent_to: to, cc: not_to_us,
                               message_thread: message) if reminder_time
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

        reminder_time = nil

        reminder_time = if local_part.match /(?!months)[a-z]{6,10}/
                          EmailParser::AdverbParser.new(to).reminder_time
                        elsif local_part.match /\d+[a-z]+/
                          EmailParser::IncrementalTime.new(to).reminder_time
                        end


        reminder_time ? reminder_time : self.calendar_date_parse(email, local_part)
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

      def extract_html_or_text(email)
        if email.html_part
          email.html_part.body.decoded
        else
          self.extract_text(email)
        end
      end

      def extract_text(email)
        if email.multipart?
          email.text_part ? email.text_part.body.decoded : nil
        else
          email.body.decoded
        end
      end

      def extract_to_us(email, parent_message)
        email.cc ||= []
        to_us = (email.to + email.cc).select{ |t| t.include?('@hound.cc') }
        to_us -= parent_message.hound_recipients if parent_message

        to_us
      end

      def extract_not_to_us(email, to_us)
        email.cc ||= []
        (email.to + email.cc) - to_us
      end
    end
  end
end
