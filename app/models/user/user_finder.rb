module User::UserFinder
  extend ActiveSupport::Concern
  UTC_ZONE = 0

  included do
    devise :invitable
  end

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
      email.from.blank? ? nil : email.from.first.to_s.downcase
    end

    def invite_without_invitation!(email)
      params = {email: from_address(email), timezone: email_time_zone(email),
                modify_token: Token.new}
      params_valid_for_user!(params)
      User.invite!(params){ |u| u.skip_invitation = true }
    end

    def params_valid_for_user!(params)
      test_user = User.new(params)
      test_user.valid?
      test_user.errors.delete(:password)
      unless test_user.errors.empty?
        raise(ActiveRecord::RecordInvalid.new(test_user))
      end
    end
  end
end
