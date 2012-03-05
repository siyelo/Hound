require 'spec_helper'

describe EmailParser::AdverbParser do
  describe "parse addresses" do
    before :each do
      @adverb = EmailParser::AdverbParser.new("tomorrow@hound.cc")
    end
    
    context "refactorings" do
      it "should be createable" do
        @adverb.email.should == "tomorrow@hound.cc"
      end

      it "should return the reminder time" do
        @adverb.reminder_time.should == 1.day.from_now.change(hour: 8)
      end
    end

    context "tomorrow" do
      it "should return 8am the next day" do
        @adverb.email = "tomorrow@sorad.cc"
        @adverb.reminder_time == 1.day.from_now.change(hour: 8)
      end
    end

    context "next{day}" do
      it "should return the next day (mon tues ect)" do
        @adverb.email = "nextmonday@sorad.cc"
        reminder_time = @adverb.reminder_time
        reminder_time.wday.should == 1
        reminder_time.hour.should == 8
      end
    end

    context "{day}" do
      it "should return the next day (mon tues ect)" do
        @adverb.email = "tuesday@sorad.cc"
        reminder_time = @adverb.reminder_time
        reminder_time.wday.should == 2
        reminder_time.hour.should == 8
      end
    end

    context "endofday" do
      it "should return 8am the next day" do
        @adverb.email = "endofday@sorad.cc"
        @adverb.reminder_time.should == Time.now.change(hour: 17)
      end
    end

    context "endofmonth" do
      it "should return 8am the last day of the month" do
        @adverb.email = "endofmonth@sorad.cc"
        t = Time.now
        resulting_time = (t.change month: t.month + 1, day: 1, hour: 8) - 1.day
        @adverb.reminder_time.should == resulting_time
      end
    end
  end
end
