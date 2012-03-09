module FindsOrInvitesUsers
  extend ActiveSupport::Concern

  module ClassMethods
    def find_or_invite(email)
      from = email.from.first.to_s
      time_zone = ActiveSupport::TimeZone[email.date.zone.to_i].name
      user = User.find_by_email_or_alias(from) ||
        User.invite!(email: from, timezone: time_zone) {|u| u.skip_invitation = true}
    end
  end
end
