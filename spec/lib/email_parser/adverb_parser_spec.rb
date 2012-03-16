require 'email_parser/adverb_parser'

describe EmailParser::AdverbParser do
  it "should return the reminder time" do
    email = "tomorrow@hound.cc"
    EmailParser::AdverbParser.parse(email).should == 1.day.from_now.change(hour: 8)
  end

  it "should return relative time using the standard ruby time zones" do
    Time.zone = 'Central Time (US & Canada)'
    email = "tomorrow@hound.cc"
    EmailParser::AdverbParser.parse(email).should == (Time.zone.now + 1.day).change(hour: 8)
  end

  it "should return 8am the next day" do
    email = "tomorrow@sorad.cc"
    EmailParser::AdverbParser.parse(email) == 1.day.from_now.change(hour: 8)
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
    EmailParser::AdverbParser.parse(email).should == Time.now.change(hour: 17)
  end

  it "should return 8am the last day of the month" do
    email = "endofmonth@sorad.cc"
    t = Time.now
    resulting_time = (t.change month: t.month + 1, day: 1, hour: 8) - 1.day
    EmailParser::AdverbParser.parse(email).should == resulting_time
  end
end
