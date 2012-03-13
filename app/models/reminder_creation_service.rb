class ReminderCreationService
  def create!(mail)
    user = User.find_or_invite!(mail)
    save_fetched_mail(mail, user)
    create_reminders(mail, user)
  end

  def parse_or_notify(to, email = nil)
    begin
      DateTime.parse_email(to)
    rescue ArgumentError
      Resque.enqueue(ErrorNotificationWorker, email) if email
      nil
    end
  end

  private

  def save_fetched_mail(mail, user)
    fetched_mail = FetchedMail.new(user: user)
    fetched_mail.from_mail(mail)
    fetched_mail.save!
  end

  def create_reminders(mail, user)
    hounds = HoundAddressList.new(mail)
    hounds.each do |h| 
      send_at = parse_or_notify(h, mail)
      #TODO smelly - fix once dispatcher is dead
      if send_at
        reminder = Reminder.create!(send_at: send_at, user: user)
      end
    end
  end

end
