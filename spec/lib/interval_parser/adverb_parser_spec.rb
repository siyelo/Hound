require 'interval_parser/adverb_parser'
require 'interval_parser/time_parser'

describe IntervalParser::AdverbParser do
  it "should return the reminder time" do
    time = "tomorrow"
    IntervalParser::AdverbParser.parse(time).should == 1.day.from_now.utc.change(hour: 8)
  end

  it "should offset the time based on the timezone" do
    time = "tomorrow"
    IntervalParser::AdverbParser.parse(time, 'Harare').should == 1.day.from_now.utc.change(hour: 6) # 6am UTC = 8am Harare
  end

  it "should default to 'UTC' if given time zone is not valid" do
    time = "tomorrow"
    IntervalParser::AdverbParser.parse(time, 'THISisntAtimezone').should == 1.day.from_now.utc.change(hour: 8)
  end

  it "should handle timezone > GMT+8" do
    time = "tomorrow"
    # Today 11pm UTC == Tomorrow 8am IRKT
    IntervalParser::AdverbParser.parse(time, 'Irkutsk').should == Time.now.utc.change(hour: 23)
  end

  it "should return 8am the next day" do
    time = "tomorrow"
    IntervalParser::AdverbParser.parse(time) == 1.day.from_now.utc.change(hour: 8)
  end

  it "should return the next day (mon tues ect)" do
    time = "nextmonday"
    send_at = IntervalParser::AdverbParser.parse(time)
    send_at.wday.should == 1
    send_at.hour.should == 8
  end

  it "should return the next day (mon tues ect)" do
    time = "tuesday"
    send_at = IntervalParser::AdverbParser.parse(time)
    send_at.wday.should == 2
    send_at.hour.should == 8
  end

  it "should return 8am the next day" do
    time = "endofday"
    IntervalParser::AdverbParser.parse(time).should == Time.now.utc.change(hour: 17)
  end

  it "should return 8am the last day of the month" do
    time = "endofmonth"
    t = Time.now.utc
    resulting_time = (t.change month: t.month + 1, day: 1, hour: 8) - 1.day
    IntervalParser::AdverbParser.parse(time).should == resulting_time
  end

  it "should return nil if not parseable" do
    time = 'eeee10am'
    IntervalParser::AdverbParser.parse(time).should == nil
  end

  it "should parse trailing 12-hour time with period" do
    time = "tomorrow10am"
    IntervalParser::AdverbParser.parse(time).should == 1.day.from_now.utc.change(hour: 10)
  end

  it "should parse leading 12-hour time with period" do
    time = "10pmtomorrow"
    IntervalParser::AdverbParser.parse(time).should == 1.day.from_now.utc.change(hour: 22)
  end

  it "should parse 12-hour time with minutes and period" do
    time = "1030amtomorrow"
    IntervalParser::AdverbParser.parse(time).should == 1.day.from_now.utc.change(hour: 10, min:30)
  end
end
