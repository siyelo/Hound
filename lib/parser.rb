module EmailParser
  class Parser
    require 'active_support/all'

    def self.parse_email(email)
      (self.scan_minutes(email) + self.scan_hours(email) +
      self.scan_days(email) + self.scan_weeks(email) +
      self.scan_months(email) +  self.scan_years(email)).from_now
    end

    def self.scan_minutes(email)
      minutes = email.scan(/(\d{1,2})(?!mo)m[a-zA-Z]*/)
      !minutes.empty? ? minutes.first[0].to_i.minutes : 0.minutes
    end

    def self.scan_hours(email)
      hours = email.scan(/(\d{1,2})ho?u?r?s?/)
      !hours.empty? ? hours.first[0].to_i.hours : 0.hours
    end

    def self.scan_days(email)
      days = email.scan(/(\d{1,2})da?y?s?/)
      !days.empty? ? days.first[0].to_i.days : 0.days
    end

    def self.scan_weeks(email)
      weeks = email.scan(/(\d{1,2})we?e?k?s?/)
      !weeks.empty? ? weeks.first[0].to_i.weeks : 0.weeks
    end

    def self.scan_months(email)
      months = email.scan(/(\d{1,2})mo[a-zA-Z]*/)
      !months.empty? ? months.first[0].to_i.months : 0.months
    end

    def self.scan_years(email)
      years = email.scan(/(\d{1,2})ye?a?r?s?/)
      !years.empty? ? years.first[0].to_i.years : 0.years
    end
  end
end



#year y
#month mo
#week w
#day d
#hour \d+h
#minute \d+m
