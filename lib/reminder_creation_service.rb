class ReminderCreationService
  def fetch_all_mails
    emails = Mail.all
    emails.each do |mail|
      create!(mail)
    end
  end

  def create!(mail)
    user = User.find_or_invite!(mail)
    fetched_mail = FetchedMail.create_from_mail!(mail, user)
    create_reminders!(fetched_mail)
  end

  private

  # create on reminder per hound address
  # unless its a reply, and the parent has the same hound address
  def create_reminders!(fetched_mail)
    FilteredAddressList.new(fetched_mail).each do |hound_address|
      create_or_notify!(hound_address, fetched_mail)
    end
  end

  # Parses an email and creates a Reminder
  # Also catches email parsing errors and sends a notification
  # throws all other exceptions
  def create_or_notify!(to, fetched_mail)
    begin
      send_at = EmailParser.parse(to)
      Reminder.create!(send_at: send_at, fetched_mail: fetched_mail,
                       is_bcc: fetched_mail.is_address_bcc?(to))
    rescue ArgumentError
      Resque.enqueue(ErrorNotificationJob, fetched_mail.id)
    end
  end
end
