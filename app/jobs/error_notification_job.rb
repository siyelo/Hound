class ErrorNotificationJob
  # This class is to remind users cc'd in an email that
  # the reminder has been snoozed or that a reminder has been changed

  @queue = :error_queue

  def self.perform(fetched_mail_id)
    fetched_mail = FetchedMail.find_by_id(fetched_mail_id)
    UserMailer.send_error_notification(fetched_mail).deliver
  end
end
