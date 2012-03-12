module FindsOrInvitesUsers
  extend ActiveSupport::Concern

  module ClassMethods
    def find_or_invite!(email)
      from = email.from.blank? ? nil : email.from.first.to_s
      zone = email.date.blank? ? nil : email.date.zone.to_i
      time_zone = ActiveSupport::TimeZone[zone].name
      debugger
      user = User.find_by_email_or_alias(from) ||
        User.invite!(email: from, timezone: time_zone) {|u| u.skip_invitation = true}
    end

  end
end
