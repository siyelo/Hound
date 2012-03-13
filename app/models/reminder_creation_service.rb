class ReminderCreationService
  def create!(mail)
    user = User.find_or_invite!(mail)
    save_fetched_mail(mail, user)
    reminder = Reminder.new(send_at: Time.now.utc + 1.hour, user: user)
    reminder.save!
  end

  private

  def save_fetched_mail(mail, user)
    fetched_mail = FetchedMail.new(user: user)
    fetched_mail.from_mail(mail)
    fetched_mail.save!
  end
end
