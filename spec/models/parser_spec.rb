require 'spec_helper'

describe EmailParser::Parser do
  describe "parse addresses" do
    before :each do
      Timecop.freeze
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
