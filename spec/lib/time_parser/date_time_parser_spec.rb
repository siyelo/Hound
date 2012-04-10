require 'time_parser/date_time_parser'

describe TimeParser::DateTimeParser do

  it "barfs on bad local parts" do
    lambda do
      TimeParser::DateTimeParser.parse('pimpin')
    end.should raise_exception ArgumentError
  end

  it "parses day month combinations (defaulting to UTC)" do
    TimeParser::DateTimeParser.parse('31Mar').should == DateTime.parse('31 Mar 08:00')
    TimeParser::DateTimeParser.parse('3July').should == DateTime.parse('3 July 08:00')
  end

  it "returns as UTC with the hour equal to 8am in given timezone" do
    TimeParser::DateTimeParser.parse('1Nov', 'Harare').should == DateTime.parse('1Nov 06:00')
  end
end
