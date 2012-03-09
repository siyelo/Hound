class ReminderCreationService
  def create(mail)
    user = User.find_or_invite(mail)
    fetched_mail = FetchedMail.new(mail)
  end
end
