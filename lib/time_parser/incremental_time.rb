module TimeParser
  require 'active_support/core_ext/numeric/time'
  require 'active_support/core_ext/integer/time'
  require 'active_support/core_ext/date_time/calculations'
  require 'active_support/core_ext/date/calculations'

  # Parses time with the following keywords;
  # year y
  # month mo
  # week w
  # day d
  # hour \d+h
  # minute \d+m
  # tomorrow
  class IncrementalTime
    ### Constants
    MATCHERS = {
      years:  /(\d{1,2})ye?a?r?s?/,
      months:  /(\d{1,2})mo[a-zA-Z]*/,
      weeks:  /(\d{1,2})we?e?k?s?/,
      days:  /(\d{1,2})da?y?s?/,
      hours:  /(\d{1,2})ho?u?r?s?/,
      minutes:  /(\d{1,2})(?!(mo|mar))m[a-zA-Z]*/
    }

    class << self
      def parse(time)
        increment = match_and_return_time(time.downcase)
        increment == 0.seconds ? nil : increment.from_now
      end

      def match_and_return_time(time)
        MATCHERS.keys.inject(0.seconds) do |result, m|
          result += scan_increments(time, m)
        end
      end

      def scan_increments(time, unit)
        increments = time.scan MATCHERS[unit]
        increments.empty? ? 0.seconds : increments.first[0].to_i.send(unit.to_sym)
      end
    end
  end
end

