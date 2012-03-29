require 'email_parser/adverb_parser'

describe EmailParser::AdverbParser do
  it "should return the reminder time" do
    email = "tomorrow@hound.cc"
    EmailParser::AdverbParser.parse(email).should == 1.day.from_now.utc.change(hour: 8)
  end

  it "should offset the time based on the timezone" do
    email = "tomorrow@hound.cc"
    EmailParser::AdverbParser.parse(email, 'Harare').should == 1.day.from_now.utc.change(hour: 6) # 6am UTC = 8am Harare
  end

  it "should default to 'UTC' if given time zone is not valid" do
    email = "tomorrow@hound.cc"
    EmailParser::AdverbParser.parse(email, 'THISisntAtimezone').should == 1.day.from_now.utc.change(hour: 8)
  end

  it "should handle timezone > GMT+8" do
    email = "tomorrow@hound.cc"
    # Today 11pm UTC == Tomorrow 8am IRKT
    EmailParser::AdverbParser.parse(email, 'Irkutsk').should == Time.now.utc.change(hour: 23)
  end

  it "should return 8am the next day" do
    email = "tomorrow@sorad.cc"
    EmailParser::AdverbParser.parse(email) == 1.day.from_now.utc.change(hour: 8)
  end

  it "should return the next day (mon tues ect)" do
    email = "nextmonday@sorad.cc"
    send_at = EmailParser::AdverbParser.parse(email)
    send_at.wday.should == 1
    send_at.hour.should == 8
  end

  it "should return the next day (mon tues ect)" do
    email = "tuesday@sorad.cc"
    send_at = EmailParser::AdverbParser.parse(email)
    send_at.wday.should == 2
    send_at.hour.should == 8
  end

  it "should return 8am the next day" do
    email = "endofday@sorad.cc"
    EmailParser::AdverbParser.parse(email).should == Time.now.utc.change(hour: 17)
  end

  it "should return 8am the last day of the month" do
    email = "endofmonth@sorad.cc"
    t = Time.now.utc
    resulting_time = (t.change month: t.month + 1, day: 1, hour: 8) - 1.day
    EmailParser::AdverbParser.parse(email).should == resulting_time
  end

  it "should return nil if not parseable" do
    email = 'tom10am@sorad.cc'
    EmailParser::AdverbParser.parse(email).should == nil
  end
end
