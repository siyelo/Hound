require 'interval_parser/incremental_time'

describe IntervalParser::IncrementalTime do
  it "should detect the minutes" do
    IntervalParser::IncrementalTime.parse("2minutes").to_i.should == 2.minutes.from_now.to_i.to_i
  end

  it "should detect the minutes (m) (complex)" do
    IntervalParser::IncrementalTime.parse("5m").to_i.should == 5.minutes.from_now.to_i
  end

  it "should detect the minutes(mi) (complex)" do
    IntervalParser::IncrementalTime.parse("5mi").to_i.should == 5.minutes.from_now.to_i
  end

  it "should detect the minutes(min) (complex)" do
    IntervalParser::IncrementalTime.parse("5min").to_i.should == 5.minutes.from_now.to_i
  end

  it "should detect the hours" do
    IntervalParser::IncrementalTime.parse("2hours").to_i.should == 2.hours.from_now.to_i
  end

  it "should detect the hours (complex)" do
    IntervalParser::IncrementalTime.parse("5h").to_i.should == 5.hours.from_now.to_i
  end

  it "should detect the days" do
    IntervalParser::IncrementalTime.parse("2days").to_i.should == 2.days.from_now.to_i
  end

  it "should detect the days (complex)" do
    IntervalParser::IncrementalTime.parse("5d").to_i.should == 5.days.from_now.to_i
  end

  it "should detect the weeks" do
    IntervalParser::IncrementalTime.parse("2weeks").to_i.should == 2.weeks.from_now.to_i
  end

  it "should detect the weeks (complex)" do
    IntervalParser::IncrementalTime.parse("5w").to_i.should == 5.weeks.from_now.to_i
  end

  it "should detect the months" do
    IntervalParser::IncrementalTime.parse("2months").to_i.should == 2.months.from_now.to_i || 2.months.from_now.to_i + 1
  end

  it "should detect the months (complex)" do
    IntervalParser::IncrementalTime.parse("5mo").to_i.should == 5.months.from_now.to_i
  end

  it "should detect the years" do
    IntervalParser::IncrementalTime.parse("2years").to_i.should == 2.years.from_now.to_i
  end

  it "should detect the years (complex)" do
    IntervalParser::IncrementalTime.parse("5y").to_i.should == 5.years.from_now.to_i
  end

  it "should detect everything" do
    IntervalParser::IncrementalTime.parse("2years3months12days23hours1minute").to_i.
      should == (2.years + 3.months + 12.days + 23.hours + 1.minute).from_now.to_i
  end

  it "should work with composite times" do
    IntervalParser::IncrementalTime.parse("2y3mo12d23h1m").to_i.
      should == (2.years + 3.months + 12.days + 23.hours + 1.minute).from_now.to_i
  end

  it "should work with a mixture of composite and non times" do
    IntervalParser::IncrementalTime.parse("2years3mo12days23h1min").to_i.
    should == (2.years + 3.months + 12.days + 23.hours + 1.minute).from_now.to_i
  end

  # if today is 30th day in a month of 31 days (and next month has 30 days)
  # then Time.now + 1.day + 1.month != Time.now + 1.month + 1.day
  # i.e.:
  # 30 March + 1.day  == 31 March
  # 31 March + 1.month = 30 April
  # -------------------------------
  # 30 March + 1.month == 30 April
  # 30 April + 1.day == 31 April

  it "should match increments in decending order (years to minutes) regardless of email order" do
    Time.stub(:now).and_return Time.parse '30-03-2011'
    IntervalParser::IncrementalTime.parse("1d1mo1y").to_i.
      should == Time.parse('31-04-2012').to_i
  end

  it "should return nil if unparseable" do
    IntervalParser::IncrementalTime.parse("jiosj").should be_nil
  end

  it "should not try parse Mar / March as minutes" do
    IntervalParser::IncrementalTime.parse("31mar").should be_nil
    IntervalParser::IncrementalTime.parse("31march").should be_nil
  end

  it "should downcase email before parsing" do
    IntervalParser::IncrementalTime.parse("5Min").to_i.should == 5.minutes.from_now.to_i
  end
end
