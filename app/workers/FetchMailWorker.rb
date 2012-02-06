class FetchMailWorker
  require 'parser'
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  @queue = :fetch_queue

  def self.perform
    emails = Mail.all
    emails.each do |e|
      user = User.find_or_invite(e)

      e.cc ||= []
      to_us = (e.to + e.cc).select{ |t| t.include?('@hound.cc') }
      not_to_us = (e.to + e.cc) - to_us

      to_us.each do |to|
        reminder_time = EmailParser::Parser.parse_email(to)
        reminder = Reminder.create!(email: e.from.first.to_s, subject: e.subject,
                                    body: EmailHelper.extract_html_or_text(e),
                                    reminder_time: reminder_time, user: user,
                                    cc: not_to_us, message_id: e.message_id)
      end
    end
  end

end
