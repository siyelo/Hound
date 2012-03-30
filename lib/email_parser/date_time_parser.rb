module EmailParser
  require 'active_support/values/time_zone'
  require 'active_support/time_with_zone'

  class DateTimeParser
    def self.parse(email, timezone = 'UTC')
      #http://en.wikipedia.org/wiki/Email_address#Local_part
      date = DateTime.parse(email.split('@')[0])
      date = date.to_time.in_time_zone(ActiveSupport::TimeZone[timezone])
      date.change(hour: 8).utc if date
    end
  end
end
