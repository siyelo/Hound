module FindsOrInvitesUsers
  extend ActiveSupport::Concern

  module ClassMethods
    def find_or_invite!(email)
      User.find_by_email_or_alias(from_address(email)) || invite_without_invitation(email)
    end

    private
    def email_time_zone(email)
      zone = email.date.blank? ? 0 : email.date.zone.to_i
      ActiveSupport::TimeZone[zone].name
    end

    def from_address(email)
      email.from.blank? ? nil : email.from.first.to_s
    end

    def invite_without_invitation(email)
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
