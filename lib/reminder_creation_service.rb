class ReminderCreationService
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
      time = to.split('@')[0]
      send_at = IntervalParser.parse(time, @user.timezone)
      if send_at
        Reminder.create!(send_at: send_at, time: time,
                         fetched_mail: @fetched_mail,
                         other_recipients: reminder_recipients(to))
      else
        enqueue_error(to)
      end
    rescue ArgumentError
      enqueue_error(to)
    end
  end

  def reminder_recipients(to)
    unless @fetched_mail.is_address_bcc?(to)
      @fetched_mail.all_addresses - HoundAddressList.new(@fetched_mail)
    else
      []
    end
  end

  def enqueue_error(to)
    Resque.enqueue(ErrorNotificationJob, @fetched_mail.id)
    Airbrake.notify(
      :error_class   => to,
      :error_message => "Invalid email format: #{to}"
    )
  end
end
