module EmailParser
  class Parser
    require 'active_support/all'
    # this is going to need a rewrite when we are done

    ### Constants

    TIME = {
      tomorrow: /tomorrow/,
      endofday: /endofday/,
      endofmonth: /endofmonth/,
      #make this regex match the day
      nextmonday: /nextmonday/,
      nexttuesday: /nexttuesday/,
      nextwednesday: /nextwednesday/,
      nextthursday: /nextthursday/,
      nextfriday: /nextfriday/,
      nextsaturday: /nextsaturday/,
      nextsunday: /nextsunday/,
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

    def self.match_time_words(email)
      TIME.keys.inject([]) { |result, m| result << email.scan(TIME[m]) }.flatten
    end

    def self.reminder_time(email)
      INCREMENTS.keys.inject(0.seconds) do |result, m|
        result += self.scan_increments(email, m)
      end
    end

    def self.scan_increments(email, unit)
      time = email.scan INCREMENTS[unit]
      time.empty? ? 0.seconds : time.first[0].to_i.send(unit.to_sym)
    end

    def self.tomorrow
      1.day.from_now.change hour: 8
    end

    def self.endofday
      Time.now.change hour: 17
    end

    def self.endofmonth
      Time.now.end_of_month.change hour: 8
    end


    def self.date_of_next(day)
      date  = DateTime.parse(day)
      delta = date > Date.today ? 0 : 7
      (date + delta).change hour: 8
    end

    def self.nextmonday
      date_of_next("monday")
    end

    def self.nexttuesday
      date_of_next("tuesday")
    end

    def self.nextwednesday
      date_of_next("wednesday")
    end

    def self.nextthursday
      date_of_next("thursday")
    end

    def self.nextfriday
      date_of_next("friday")
    end

    def self.nextsaturday
      date_of_next("saturday")
    end

    def self.nextsunday
      date_of_next("sunday")
    end

    def self.nextweek
      Time.now.next_week.change hour: 8
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
