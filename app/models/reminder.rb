class Reminder < ActiveRecord::Base
  require 'parser'

  ### Associations
  belongs_to :user

  # Validations
  validates_presence_of :email, :subject, :reminder_time, :user

  ### Class methods
  def self.fetch_reminders
    time = Time.now.change(sec: 0)
    last_time = time + 59.seconds

    self.select("id, user_id").where("reminder_time >= ? AND reminder_time <= ? AND delivered = ?",
      time, last_time, false).includes(:user)
  end

  ### Instance methods
  def add_to_send_queue
    Resque.enqueue(SendMailWorker, self.id)
  end

  def email_to_reminder(e)
    reminder_time = EmailParser::Parser.parse_email(e.to.first.to_s)
    user = find_or_invite_user(e.from.first.to_s)
    reminder = Reminder.create!(email: e.from.first.to_s, subject: e.subject,
                body: e.body.to_s, reminder_time: reminder_time, user: user)
  end

  def send_reminder_email
    puts "in sendmailworker"
    # this is necessary because we may have more than one worker polling
    unless delivered?
      UserMailer.send_reminder(self).deliver
      self.delivered = true
      self.save!
    end
  end

  private

  def find_or_invite_user(email)
    User.find_or_invite(email)
  end
end
