require 'time_parser/adverb_parser'

describe TimeParser::AdverbParser do
  it "should return the reminder time" do
    time = "tomorrow"
    TimeParser::AdverbParser.parse(time).should == 1.day.from_now.utc.change(hour: 8)
  end

  it "should offset the time based on the timezone" do
    time = "tomorrow"
    TimeParser::AdverbParser.parse(time, 'Harare').should == 1.day.from_now.utc.change(hour: 6) # 6am UTC = 8am Harare
  end

  it "should default to 'UTC' if given time zone is not valid" do
    time = "tomorrow"
    TimeParser::AdverbParser.parse(time, 'THISisntAtimezone').should == 1.day.from_now.utc.change(hour: 8)
  end

  it "should handle timezone > GMT+8" do
    time = "tomorrow"
    # Today 11pm UTC == Tomorrow 8am IRKT
    TimeParser::AdverbParser.parse(time, 'Irkutsk').should == Time.now.utc.change(hour: 23)
  end

  it "should return 8am the next day" do
    time = "tomorrow"
    TimeParser::AdverbParser.parse(time) == 1.day.from_now.utc.change(hour: 8)
  end

  it "should return the next day (mon tues ect)" do
    time = "nextmonday"
    send_at = TimeParser::AdverbParser.parse(time)
    send_at.wday.should == 1
    send_at.hour.should == 8
  end

  it "should return the next day (mon tues ect)" do
    time = "tuesday"
    send_at = TimeParser::AdverbParser.parse(time)
    send_at.wday.should == 2
    send_at.hour.should == 8
  end

  it "should return 8am the next day" do
    time = "endofday"
    TimeParser::AdverbParser.parse(time).should == Time.now.utc.change(hour: 17)
  end

  it "should return 8am the last day of the month" do
    time = "endofmonth"
    t = Time.now.utc
    resulting_time = (t.change month: t.month + 1, day: 1, hour: 8) - 1.day
    TimeParser::AdverbParser.parse(time).should == resulting_time
  end

  it "should return nil if not parseable" do
    time = 'tom10am'
    TimeParser::AdverbParser.parse(time).should == nil
  end
end