class ReminderCreationService
  def create!(mail)
    user = User.find_or_invite!(mail)
    save_fetched_mail(mail, user)
    create_reminders(mail, user)
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
      send_at = EmailParser.parse_email(h, mail)
      reminder = Reminder.new(send_at: send_at, user: user)
      reminder.save!
    end
  end
end
