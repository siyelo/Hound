module EmailParser
  class Dispatcher
    def self.dispatch(emails)
      emails.each do |e|
        user = User.find_or_invite(e)

        e.cc ||= []
        to_us = (e.to + e.cc).select{ |t| t.include?('@hound.cc') }
        not_to_us = (e.to + e.cc) - to_us

        to_us.each do |to|
          reminder_time = self.parse_email(to)
          reminder = Reminder.create!(email: e.from.first.to_s, subject: e.subject,
                                      body: EmailHelper.extract_html_or_text(e),
                                      reminder_time: reminder_time, user: user,
                                      cc: not_to_us, message_id: e.message_id)
        end
      end
    end

    private

    ### Factory for dispatching emails to the correct parser
    def self.parse_email(email)
      # local part is the first part of the email
      # we use this to determine when the email should be returned
      local_part = email.split('@')[0] || email

      reminder_time = nil
      reminder_time = if local_part.match /(?!months)[a-z]{6,10}/
                        EmailParser::Parser.parse_email(email)
                      elsif local_part.match /\d+[a-z]+/
                        EmailParser::IncrementalTime.parse_email(email)
                      end
    end
  end
end
