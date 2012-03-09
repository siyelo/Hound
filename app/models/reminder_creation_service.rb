class ReminderCreationService
  def create!(mail)
    user = User.find_or_invite!(mail)
    save_fetched_mail(mail)
    reminder = Reminder.new(send_at: 1.hour.from_now).save!
  end

  private

  def save_fetched_mail(mail)
    fetched_mail = FetchedMail.new
    fetched_mail.from_mail(mail)
    fetched_mail.save!
  end
end
