module TimeParser
  require 'active_support/core_ext/date_time/calculations'
  require 'time_parser/adverb_parser'
  require 'time_parser/incremental_time'
  require 'time_parser/date_time_parser'

  def self.parse(time, timezone = 'UTC')
    TimeParser::AdverbParser.parse(time, timezone) ||
      TimeParser::IncrementalTime.parse(time) ||
      TimeParser::DateTimeParser.parse(time, timezone)
  end
end
