class ReminderCreationService

  def initialize(mail_klass = Mail, reminder_klass = Reminder,
                 user_klass = User, parser_klass = EmailParser::Dispatcher)
    @mail_klass = mail_klass
    @reminder_klass = reminder_klass
    @user_klass = user_klass
    @parser_klass= parser_klass
  end

  def create(email_params)
    mail = @mail_klass.create(email_params)
    user = find_or_invite(mail.from, mail.date.zone)
    send_at = @parser_klass.parse_email(mail.to)
    reminder = @reminder_klass.create(user, send_at, mail)
  end

  private

    def find_or_invite(email_address, zone)
      time_zone = ActiveSupport::TimeZone[zone.to_i].name
      user = @user_klass.find_by_email_or_alias(email_address) ||
        @user_klass.invite!(email: email_address, timezone: time_zone) {|u| u.skip_invitation = true}
    end
end
