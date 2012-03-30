require 'email_parser/date_time_parser'

describe EmailParser::DateTimeParser do

  it "barfs on bad local parts" do
    lambda do
      EmailParser::DateTimeParser.parse('pimpin@hound.cc')
    end.should raise_exception ArgumentError
  end

  it "parses day month combinations (defaulting to UTC)" do
    EmailParser::DateTimeParser.parse('31Mar@hound.cc').should == DateTime.parse('31 Mar 08:00')
    EmailParser::DateTimeParser.parse('3July@hound.cc').should == DateTime.parse('3 July 08:00')
  end

  it "returns as UTC with the hour equal to 8am in given timezone" do
    EmailParser::DateTimeParser.parse('1Nov@hound.cc', 'Harare').should == DateTime.parse('1Nov 06:00')
  end

end
