require 'interval_parser/date_time_parser'
require 'interval_parser/time_parser'

describe IntervalParser::DateTimeParser do

  it "barfs on bad local parts" do
    IntervalParser::DateTimeParser.parse('pimpin').should be_nil
  end

  it "parses day month combinations (defaulting to UTC)" do
    IntervalParser::DateTimeParser.parse('31Mar').should == DateTime.parse('31 Mar 08:00')
    IntervalParser::DateTimeParser.parse('3July').should == DateTime.parse('3 July 08:00')
  end

  it "parses day month time combinations (defaulting to UTC)" do
    IntervalParser::DateTimeParser.parse('31Mar1030am').should == DateTime.parse('31 Mar 10:30')
    IntervalParser::DateTimeParser.parse('3July10pm').should == DateTime.parse('3 July 22:00')
    IntervalParser::DateTimeParser.parse('10pm3July2013').should == DateTime.parse('3 July 2013 22:00')
  end

  it "returns as UTC with the hour equal to 8am in given timezone" do
    IntervalParser::DateTimeParser.parse('1Nov', 'Harare').should == DateTime.parse('1Nov 06:00')
  end

end
