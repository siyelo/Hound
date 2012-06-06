require 'interval_parser/time_parser'

describe IntervalParser::TimeParser do
  it "should return the reminder time - 12 hour format with period" do
    time = "10am"
    IntervalParser::TimeParser.parse(time).hour.should == 10
    IntervalParser::TimeParser.parse(time).min.should == 00
    time = "10pm"
    IntervalParser::TimeParser.parse(time).hour.should == 22
    IntervalParser::TimeParser.parse(time).min.should == 00
    time = "9pm"
    IntervalParser::TimeParser.parse(time).hour.should == 21
    IntervalParser::TimeParser.parse(time).min.should == 00
  end

  it "should return the reminder time - 12 hour format with period and minutes" do
    time = "1030am"
    IntervalParser::TimeParser.parse(time).hour.should == 10
    IntervalParser::TimeParser.parse(time).min.should == 30
    time = "1030pm"
    IntervalParser::TimeParser.parse(time).hour.should == 22
    IntervalParser::TimeParser.parse(time).min.should == 30
    time = "930pm"
    IntervalParser::TimeParser.parse(time).hour.should == 21
    IntervalParser::TimeParser.parse(time).min.should == 30
  end

  it "should return the reminder time - 24 hour format" do
    time = "22"
    IntervalParser::TimeParser.parse(time).hour.should == 22
    IntervalParser::TimeParser.parse(time).min.should == 00
    time = "10"
    IntervalParser::TimeParser.parse(time).hour.should == 10
    IntervalParser::TimeParser.parse(time).min.should == 00
    time = "9"
    IntervalParser::TimeParser.parse(time).hour.should == 9
    IntervalParser::TimeParser.parse(time).min.should == 00
  end

  it "should return the reminder time - 24 hour format with minutes" do
    time = "2230"
    IntervalParser::TimeParser.parse(time).hour.should == 22
    IntervalParser::TimeParser.parse(time).min.should == 30
    time = "1030"
    IntervalParser::TimeParser.parse(time).hour.should == 10
    IntervalParser::TimeParser.parse(time).min.should == 30
    time = "930"
    IntervalParser::TimeParser.parse(time).hour.should == 9
    IntervalParser::TimeParser.parse(time).min.should == 30
  end

  it "should set the time in the future" do
    time = (Time.now.utc.hour - 1).to_s
    IntervalParser::TimeParser.parse("#{time}am").day.should == Time.now.utc.day + 1
  end

  it "should adjust the UTC time based on the given time zone" do
    time = '10am'
    IntervalParser::TimeParser.parse(time, 'Harare').hour.should == 8 #10am CAT == 8am UTC
  end
end
