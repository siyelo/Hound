class CleanMailJob
  # This class is to clean private data from delivered reminders
  # older than 2 weeks

  @queue = :clean_queue

  def self.perform
    Reminder.old.delivered.uncleaned.each do |reminder|
      clean_reminder(reminder)
    end
  end

  private
    def self.clean_reminder(reminder)
      reminder.email = nil
      reminder.other_recipients = []
      reminder.cleaned = true
      reminder.save!

      fetched_mail = reminder.fetched_mail
      fetched_mail.cc          = []
      fetched_mail.bcc         = []
      fetched_mail.subject     = nil
      fetched_mail.body        = nil
      fetched_mail.in_reply_to = nil
      fetched_mail.save!
    end
end
