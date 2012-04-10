module TimeParser
  require 'active_support/values/time_zone'
  require 'active_support/time_with_zone'

  class DateTimeParser
    def self.parse(time, timezone = 'UTC')
      #http://en.wikipedia.org/wiki/Email_address#Local_part
      date = DateTime.parse(time)
      date = date.to_time.in_time_zone(ActiveSupport::TimeZone[timezone])
      date.change(hour: 8).utc if date
    end
  end
end
