require 'spec_helper'

describe EmailParser::Parser do
  describe "parse addresses" do
    before :each do
      Timecop.freeze
    end

    context "tomorrow" do
      it "should return 8am the next day" do
        email = "tomorrow@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 1.day.from_now.change(hour: 8)
      end
    end

    context "next{day}" do
      it "should return the next day (mon tues ect)" do
        email = "nextmonday@sorad.cc"
        EmailParser::Parser.parse_email(email).wday.should == 1
        EmailParser::Parser.parse_email(email).hour.should == 8
      end
    end

    context "{day}" do
      it "should return the next day (mon tues ect)" do
        email = "monday@sorad.cc"
        EmailParser::Parser.parse_email(email).wday.should == 1
        EmailParser::Parser.parse_email(email).hour.should == 8
      end
    end

    context "endofday" do
      it "should return 8am the next day" do
        email = "endofday@sorad.cc"
        EmailParser::Parser.parse_email(email).should == Time.now.change(hour: 17)
      end
    end

    context "endofmonth" do
      it "should return 8am the last day of the month" do
        email = "endofmonth@sorad.cc"
        t = Time.now
        resulting_time = (t.change month: t.month + 1, day: 1, hour: 8) - 1.day
        EmailParser::Parser.parse_email(email).should == resulting_time
      end
    end
  end
end
