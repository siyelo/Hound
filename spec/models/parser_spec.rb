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

    context "minutes" do
      it "should detect the minutes" do
        email = "2minutes@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 2.minutes.from_now
      end

      it "should detect the minutes (m) (complex)" do
        email = "5m@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 5.minutes.from_now
      end

      it "should detect the minutes(mi) (complex)" do
        email = "5mi@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 5.minutes.from_now
      end

      it "should detect the minutes(min) (complex)" do
        email = "5min@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 5.minutes.from_now
      end
    end

    context "hours" do
      it "should detect the hours" do
        email = "2hours@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 2.hours.from_now
      end

      it "should detect the days (complex)" do
        email = "5h@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 5.hours.from_now
      end
    end

    context "days" do
      it "should detect the days" do
        email = "2days@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 2.days.from_now
      end

      it "should detect the days (complex)" do
        email = "5d@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 5.days.from_now
      end
    end

    context "weeks" do
      it "should detect the weeks" do
        email = "2weeks@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 2.weeks.from_now
      end

      it "should detect the weeks (complex)" do
        email = "5w@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 5.weeks.from_now
      end
    end

    context "months" do
      it "should detect the months" do
        email = "2months@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 2.months.from_now
      end

      it "should detect the months (complex)" do
        email = "5mo@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 5.months.from_now
      end
    end

    context "years" do
      it "should detect the years" do
        email = "2years@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 2.years.from_now
      end

      it "should detect the years (complex)" do
        email = "5y@sorad.cc"
        EmailParser::Parser.parse_email(email).should == 5.years.from_now
      end
    end

    context "combined" do
      it "should detect everything" do
        email = "2years3months12days23hours1minute@sorad.cc"
        EmailParser::Parser.parse_email(email).should == (2.years + 3.months + 12.days +
                                                          23.hours + 1.minute).from_now
      end

      it "should work with composite times" do
        email = "2y3mo12d23h1m@sorad.cc"
        EmailParser::Parser.parse_email(email).should == (2.years + 3.months + 12.days +
                                                          23.hours + 1.minute).from_now
      end

      it "should work with a mixture of composite and non times" do
        email = "2years3mo12days23h1min@sorad.cc"
        EmailParser::Parser.parse_email(email).should == (2.years + 3.months + 12.days +
                                                          23.hours + 1.minute).from_now
      end
    end
  end
end
