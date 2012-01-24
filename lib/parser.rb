module EmailParser
  class Parser
    require 'active_support/all'

    ### Constants

    MEASUREMENT = {
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

      def self.reminder_time(email)
        MEASUREMENT.keys.inject(0.seconds) do |result, m|
          result += self.scan_time(email, m)
        end
      end

      def self.scan_time(email, unit)
        time = email.scan MEASUREMENT[unit]
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
