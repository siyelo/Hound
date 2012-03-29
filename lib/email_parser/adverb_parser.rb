module EmailParser
  require 'active_support/core_ext/numeric/time'
  require 'active_support/core_ext/integer/time'
  require 'active_support/core_ext/date_time/calculations'
  require 'active_support/core_ext/date/calculations'
  require 'active_support/values/time_zone'
  require 'active_support/time_with_zone'

  class AdverbParser
    ### Constants
    STARTOFDAY = 8
    ENDOFDAY = 17
    SECONDS_IN_HOUR = 3600

    DAYSOFWEEK = [:monday, :tuesday, :wednesday,
                  :thursday, :friday, :saturday, :sunday]

    MATCHERS = {
      tomorrow: /tomorrow/,
      endofday: /endofday/,
      endofmonth: /endofmonth/,
      nextmonday: /nextmonday/,
      monday: /monday/,
      nexttuesday: /nexttuesday/,
      tuesday: /tuesday/,
      nextwednesday: /nextwednesday/,
      wednesday: /wednesday/,
      nextthursday: /nextthursday/,
      thursday: /thursday/,
      nextfriday: /nextfriday/,
      friday: /friday/,
      nextsaturday: /nextsaturday/,
      saturday: /saturday/,
      nextsunday: /nextsunday/,
      sunday: /sunday/,
      nextweek: /nextweek/
    }

    ### Instance Methods
    class << self
      def parse(email, zone = 'UTC')
        matches = match_key_words(email)
        unless matches.empty?
          match = self.send(matches.first)
          return utc_offset(match, zone)
        end
      end

      def match_key_words(email)
        MATCHERS.keys.inject([]) { |result, m| result << email.scan(MATCHERS[m]) }.flatten
      end

      def tomorrow
        1.day.from_now.utc.change hour: STARTOFDAY
      end

      def endofday
        Time.now.utc.change hour: ENDOFDAY
      end

      def endofmonth
        Time.now.end_of_month.utc.change hour: STARTOFDAY
      end

      def nextweek
        Time.now.next_week.utc.change hour: STARTOFDAY
      end

      DAYSOFWEEK.each do |d|
        define_method d do
          date_of_next(d.to_s)
        end
      end

      DAYSOFWEEK.each do |d|
        define_method "next#{d}" do
          date_of_next(d.to_s)
        end
      end

      def date_of_next(day)
        date  = DateTime.parse(day).to_time
        delta = date > Date.today ? 0 : 7
        (date + delta).change hour: STARTOFDAY
      end

      private

      def utc_offset(utc_time, zone)
        tz_time = utc_time.in_time_zone(ActiveSupport::TimeZone[zone])
        tz_time = tz_time.change hour: utc_time.hour
        tz_time.utc
      end
    end
  end
end
