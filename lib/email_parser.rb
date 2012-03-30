module EmailParser
  require 'active_support/core_ext/date_time/calculations'
  require 'email_parser/adverb_parser'
  require 'email_parser/incremental_time'
  require 'email_parser/date_time_parser'

  def self.parse(address, timezone = 'UTC')
    EmailParser::AdverbParser.parse(address, timezone) ||
      EmailParser::IncrementalTime.parse(address) ||
      EmailParser::DateTimeParser.parse(address, timezone)
  end
end
