module EmailParser
  class Parser
    require 'active_support/all'

    def self.parse_email(email, start_date = nil)
      regex = /((\d+)([a-z]+))/
      result = email.scan regex
      sum = result.sum { |r| r[1].to_i.send(r[2]) }
      start_date ? start_date + sum : sum.from_now
    end
  end
end
