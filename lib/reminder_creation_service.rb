class ReminderCreationService
  def fetch_all_mails
    emails = Mail.all
    emails.each do |mail|
      create!(mail)
    end
  end

  def create!(mail)
    @user = User.find_or_invite!(mail)
    @fetched_mail = FetchedMail.create_from_mail!(mail, @user)
    create_reminders!
  end

  private

  # create on reminder per hound address
  # unless its a reply, and the parent has the same hound address
  def create_reminders!
    FilteredAddressList.new(@fetched_mail).each do |hound_address|
      create_or_notify!(hound_address)
    end
  end

  # Parses an email and creates a Reminder
  # Also catches email parsing errors and sends a notification
  # throws all other exceptions
  def create_or_notify!(to)
    begin
      send_at = EmailParser.parse(to, @user.timezone)
      Reminder.create!(send_at: send_at, fetched_mail: @fetched_mail,
                       other_recipients: reminder_recipients(to))
    rescue ArgumentError
      Resque.enqueue(ErrorNotificationJob, @fetched_mail.id)
    end
  end

  def reminder_recipients(to)
    unless @fetched_mail.is_address_bcc?(to)
      @fetched_mail.all_addresses - HoundAddressList.new(@fetched_mail)
    else
      []
    end
  end
end
