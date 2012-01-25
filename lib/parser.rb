module EmailParser
  class Parser
    require 'active_support/all'
    # this is going to need a rewrite when we are done

    ### Constants

    STARTOFDAY = 8
    ENDOFDAY = 17

    DAYSOFWEEK = [:monday, :tuesday, :wednesday,
                  :thursday, :friday, :saturday, :sunday]

    TIME = {
      tomorrow: /tomorrow/,
      endofday: /endofday/,
      endofmonth: /endofmonth/,
      #make this regex match the day
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

    INCREMENTS = {
      minutes:  /(\d{1,2})(?!mo)m[a-zA-Z]*/,
      hours:  /(\d{1,2})ho?u?r?s?/,
      days:  /(\d{1,2})da?y?s?/,
      weeks:  /(\d{1,2})we?e?k?s?/,
      months:  /(\d{1,2})mo[a-zA-Z]*/,
      years:  /(\d{1,2})ye?a?r?s?/
    }

    ### Class methods

    def self.parse_email(email, start_date = nil)
      matches = self.match_time_words(email)
      unless matches.empty?
        self.send(matches.first)
      else
        start_date ? start_date + self.reminder_time(email) : self.reminder_time(email).from_now
      end
    end

    private


    class << self
      def match_time_words(email)
        TIME.keys.inject([]) { |result, m| result << email.scan(TIME[m]) }.flatten
      end

      def reminder_time(email)
        INCREMENTS.keys.inject(0.seconds) do |result, m|
          result += self.scan_increments(email, m)
        end
      end

      def scan_increments(email, unit)
        time = email.scan INCREMENTS[unit]
        time.empty? ? 0.seconds : time.first[0].to_i.send(unit.to_sym)
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

#year y
#month mo
#week w
#day d
#hour \d+h
#minute \d+m
#tomorrow
