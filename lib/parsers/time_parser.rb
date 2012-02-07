module EmailParser
  class IncrementalTime
    require 'active_support/all'
    # this is going to need a rewrite when we are done

    ### Constants

    MATCHERS = {
      minutes:  /(\d{1,2})(?!mo)m[a-zA-Z]*/,
      hours:  /(\d{1,2})ho?u?r?s?/,
      days:  /(\d{1,2})da?y?s?/,
      weeks:  /(\d{1,2})we?e?k?s?/,
      months:  /(\d{1,2})mo[a-zA-Z]*/,
      years:  /(\d{1,2})ye?a?r?s?/
    }

    ### Class methods

    def self.parse_email(email, start_date = nil)
      start_date ? start_date + self.reminder_time(email) : self.reminder_time(email).from_now
    end

    private


    class << self

      def reminder_time(email)
        MATCHERS.keys.inject(0.seconds) do |result, m|
          result += self.scan_increments(email, m)
        end
      end

      def scan_increments(email, unit)
        time = email.scan MATCHERS[unit]
        time.empty? ? 0.seconds : time.first[0].to_i.send(unit.to_sym)
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
