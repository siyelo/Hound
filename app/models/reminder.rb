class Reminder < ActiveRecord::Base
  ### Associations
  belongs_to :user

  # Validations
  validates_presence_of :email, :subject, :reminder_time

  ### Class methods
  def self.fetch_reminders
    time = Time.now.change(sec: 0)
    last_time = time + 59.seconds

    self.select("id").where("reminder_time >= ? AND reminder_time <= ?",
      time, last_time)
  end

  ### Instance methods
  def add_to_send_queue
    Resque.enqueue(SendMailWorker, self.id)
  end
end
