class FetchMailWorker
  require 'parser'
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  @queue = :fetch_queue

  def self.perform
    emails = Mail.all
    emails.each do |e|
      #user = User.find_or_invite(e.from.first.to_s)
      user = User.find_or_invite(e)
      reminder_time = EmailParser::Parser.parse_email(e.to.first.to_s)
      reminder = Reminder.create!(email: e.from.first.to_s, subject: e.subject,
                  body: EmailHelper.extract_html_or_text(e),
                  reminder_time: reminder_time, user: user)
    end
  end

end
