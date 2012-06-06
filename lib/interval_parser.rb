module IntervalParser
  require 'active_support/core_ext/date_time/calculations'
  require 'interval_parser/adverb_parser'
  require 'interval_parser/time_parser'
  require 'interval_parser/incremental_time'
  require 'interval_parser/date_time_parser'

  def self.parse(time, timezone = 'UTC')
    IntervalParser::AdverbParser.parse(time, timezone) ||
      IntervalParser::IncrementalTime.parse(time) ||
      IntervalParser::DateTimeParser.parse(time, timezone) ||
      IntervalParser::TimeParser.parse(time, timezone)
  end
end
