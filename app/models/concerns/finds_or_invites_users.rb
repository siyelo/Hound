module FindsOrInvitesUsers
  extend ActiveSupport::Concern
  UTC_ZONE = 0

  module ClassMethods
    def find_or_invite!(email)
      User.find_by_email_or_alias(from_address(email)) || invite_without_invitation!(email)
    end

    private

    def email_time_zone(email)
      zone = email.date.blank? ? UTC_ZONE : email.date.zone.to_i
      ActiveSupport::TimeZone[zone].name
    end

    def from_address(email)
      email.from.blank? ? nil : email.from.first.to_s
    end

    def invite_without_invitation!(email)
      debugger
      user = User.new(email: from_address(email), timezone: email_time_zone(email))
      user.valid?
      user.errors.delete(:password)
      if user.errors.empty?
        user.invite!{ |u| u.skip_invitation = true }
      else
        raise(ActiveRecord::RecordInvalid.new(user))
      end
      user
    end
  end
end
