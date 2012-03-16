module EmailParser
  require 'active_support/core_ext/numeric/time'
  require 'active_support/core_ext/integer/time'
  require 'active_support/core_ext/date_time/calculations'
  require 'active_support/core_ext/date/calculations'

  class AdverbParser
    ### Constants
    STARTOFDAY = 8
    ENDOFDAY = 17

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
      def parse(email)
        matches = match_key_words(email)
        self.send(matches.first) unless matches.empty?
      end

      def match_key_words(email)
        MATCHERS.keys.inject([]) { |result, m| result << email.scan(MATCHERS[m]) }.flatten
      end

      def tomorrow
        1.day.from_now.change hour: STARTOFDAY
      end

      def endofday
        Time.now.change hour: ENDOFDAY
      end

      def endofmonth
        Time.now.end_of_month.change hour: STARTOFDAY
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
        date  = DateTime.parse(day)
        delta = date > Date.today ? 0 : 7
        (date + delta).change hour: STARTOFDAY
      end

      def nextweek
        Time.now.next_week.change hour: STARTOFDAY
      end
    end
  end
end
