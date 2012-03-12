class ReminderCreationService
  def create!(mail)
    debugger
    user = User.find_or_invite!(mail)
    save_fetched_mail(mail, user)
    reminder = Reminder.new(send_at: 1.hour.from_now).save!
  end

  private

  def save_fetched_mail(mail, user)
    fetched_mail = FetchedMail.new(user: user)
    fetched_mail.from_mail(mail)
    fetched_mail.save!
  end
end
