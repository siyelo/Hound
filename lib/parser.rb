module EmailParser
  class Parser
    require 'active_support/all'

    def self.parse_email(email, start_date = nil)
      start_date ? start_date + self.reminder_time(email) : self.reminder_time(email).from_now
    end

    private

      def self.reminder_time(email)
        [:minutes, :hours, :days, :weeks,
         :months, :years].inject(0.seconds) do |result, m|
          result += self.scan_time(email, m)
        end
      end

      def self.get_regex(measurement)
        case measurement
        when :minutes then /(\d{1,2})(?!mo)m[a-zA-Z]*/
        when :hours then /(\d{1,2})ho?u?r?s?/
        when :days then /(\d{1,2})da?y?s?/
        when :weeks then /(\d{1,2})we?e?k?s?/
        when :months then /(\d{1,2})mo[a-zA-Z]*/
        when :years then /(\d{1,2})ye?a?r?s?/
        end
      end

      def self.scan_time(email, unit)
        time = email.scan self.get_regex(unit)
        !time.empty? ? time.first[0].to_i.send(unit.to_sym) : 0.seconds
      end
  end
end



#year y
#month mo
#week w
#day d
#hour \d+h
#minute \d+m
