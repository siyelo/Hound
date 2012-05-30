module RemindersHelper
  def allow_changes(reminder)
    reminder.send_at < DateTime.now && reminder.delivered
  end

  def reminder_subject(reminder)
    reminder.subject.blank? ? '<No Subject>' : reminder.subject
  end

  def formatted_send_at(reminder)
    reminder.send_at.in_time_zone(reminder.user.timezone).
      to_formatted_s(:rfc822_with_zone)
  end

  def recipient_addresses(reminder)
    @addresses ||= reminder.fetched_mail.all_addresses.
      select{ |e| !e.include?("hound.cc") }
  end
end
