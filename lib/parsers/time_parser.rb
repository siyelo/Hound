module EmailParser
  class IncrementalTime
    require 'active_support/all'
    # this is going to need a rewrite when we are done

    attr_accessor :email

    def initialize(email)
      @email = email
    end

    ### Constants

    MATCHERS = {
      minutes:  /(\d{1,2})(?!mo)m[a-zA-Z]*/,
      hours:  /(\d{1,2})ho?u?r?s?/,
      days:  /(\d{1,2})da?y?s?/,
      weeks:  /(\d{1,2})we?e?k?s?/,
      months:  /(\d{1,2})mo[a-zA-Z]*/,
      years:  /(\d{1,2})ye?a?r?s?/
    }

    ### Instance Methods

    def reminder_time
      match_and_return_time.from_now
    end

    private

    def match_and_return_time
      MATCHERS.keys.inject(0.seconds) do |result, m|
        result += scan_increments(m)
      end
    end

    def scan_increments(unit)
      time = email.scan MATCHERS[unit]
      time.empty? ? 0.seconds : time.first[0].to_i.send(unit.to_sym)
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
