class FetchMailWorker
  require 'parser'
  # This class is responsible for fetching the emails.
  # It then delegates any further actions to the other classes

  @queue = :fetch_queue

  def self.perform
    puts "in fetchmailworker"
    emails = Mail.all
    emails.each do |e|
      user = User.find_or_invite(e.from.first.to_s)
      reminder_time = EmailParser::Parser.parse_email(e.to.first.to_s)
      reminder = Reminder.create!(email: e.from.first.to_s, subject: e.subject,
                  body: e.body.to_s, :reminder_time => reminder_time, user: user)
    end
  end

end
