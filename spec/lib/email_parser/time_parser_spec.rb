require 'spec_helper'

describe EmailParser::IncrementalTime do
  describe "parse addresses" do
    before :each do
      @time = EmailParser::IncrementalTime.new("2minutes@hound.cc")
    end

    context "minutes" do
      it "should detect the minutes" do
        @time.email = "2minutes@sorad.cc"
        @time.reminder_time.to_i.should == 2.minutes.from_now.to_i.to_i
      end

      it "should detect the minutes (m) (complex)" do
        @time.email = "5m@sorad.cc"
        @time.reminder_time.to_i.should == 5.minutes.from_now.to_i
      end

      it "should detect the minutes(mi) (complex)" do
        @time.email = "5mi@sorad.cc"
        @time.reminder_time.to_i.should == 5.minutes.from_now.to_i
      end

      it "should detect the minutes(min) (complex)" do
        @time.email = "5min@sorad.cc"
        @time.reminder_time.to_i.should == 5.minutes.from_now.to_i
      end
    end

    context "hours" do
      it "should detect the hours" do
        @time.email = "2hours@sorad.cc"
        @time.reminder_time.to_i.should == 2.hours.from_now.to_i
      end

      it "should detect the hours (complex)" do
        @time.email = "5h@sorad.cc"
        @time.reminder_time.to_i.should == 5.hours.from_now.to_i
      end
    end

    context "days" do
      it "should detect the days" do
        @time.email = "2days@sorad.cc"
        @time.reminder_time.to_i.should == 2.days.from_now.to_i
      end

      it "should detect the days (complex)" do
        @time.email = "5d@sorad.cc"
        @time.reminder_time.to_i.should == 5.days.from_now.to_i
      end
    end

    context "weeks" do
      it "should detect the weeks" do
        @time.email = "2weeks@sorad.cc"
        @time.reminder_time.to_i.should == 2.weeks.from_now.to_i
      end

      it "should detect the weeks (complex)" do
        @time.email = "5w@sorad.cc"
        @time.reminder_time.to_i.should == 5.weeks.from_now.to_i
      end
    end

    context "months" do
      it "should detect the months" do
        @time.email = "2months@sorad.cc"
        @time.reminder_time.to_i.should == 2.months.from_now.to_i || 2.months.from_now.to_i + 1
      end

      it "should detect the months (complex)" do
        @time.email = "5mo@sorad.cc"
        @time.reminder_time.to_i.should == 5.months.from_now.to_i
      end
    end

    context "years" do
      it "should detect the years" do
        @time.email = "2years@sorad.cc"
        @time.reminder_time.to_i.should == 2.years.from_now.to_i
      end

      it "should detect the years (complex)" do
        @time.email = "5y@sorad.cc"
        @time.reminder_time.to_i.should == 5.years.from_now.to_i
      end
    end

    context "combined" do
      it "should detect everything" do
        @time.email = "2years3months12days23hours1minute@sorad.cc"
        @time.reminder_time.to_i.should == (2.years + 3.months + 12.days +
                                       23.hours + 1.minute).from_now.to_i
      end

      it "should work with composite times" do
        @time.email = "2y3mo12d23h1m@sorad.cc"
        @time.reminder_time.to_i.should == (2.years + 3.months + 12.days +
                                       23.hours + 1.minute).from_now.to_i
      end

      it "should work with a mixture of composite and non times" do
        @time.email = "2years3mo12days23h1min@sorad.cc"
        @time.reminder_time.to_i.should == (2.years + 3.months + 12.days +
                                       23.hours + 1.minute).from_now.to_i
      end
    end
  end
end
