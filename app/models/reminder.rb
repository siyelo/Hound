class Reminder < ActiveRecord::Base
  ### Associations
  belongs_to :user

  # Validations
  validates_presence_of :email, :subject, :reminder_time, :user

  ### Class methods
  def self.fetch_reminders
    time = Time.now.change(sec: 0)
    last_time = time + 59.seconds

    self.select("id").where("reminder_time >= ? AND reminder_time <= ? AND delivered = ?",
                            time, last_time, false)
  end

  ### Instance methods
  def add_to_send_queue
    Resque.enqueue(SendMailWorker, self.id)
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
end
