require 'email_parser/incremental_time'

describe EmailParser::IncrementalTime do
  it "should detect the minutes" do
    EmailParser::IncrementalTime.parse("2minutes@sorad.cc").to_i.should == 2.minutes.from_now.to_i.to_i
  end

  it "should detect the minutes (m) (complex)" do
    EmailParser::IncrementalTime.parse("5m@sorad.cc").to_i.should == 5.minutes.from_now.to_i
  end

  it "should detect the minutes(mi) (complex)" do
    EmailParser::IncrementalTime.parse("5mi@sorad.cc").to_i.should == 5.minutes.from_now.to_i
  end

  it "should detect the minutes(min) (complex)" do
    EmailParser::IncrementalTime.parse("5min@sorad.cc").to_i.should == 5.minutes.from_now.to_i
  end

  it "should detect the hours" do
    EmailParser::IncrementalTime.parse("2hours@sorad.cc").to_i.should == 2.hours.from_now.to_i
  end

  it "should detect the hours (complex)" do
    EmailParser::IncrementalTime.parse("5h@sorad.cc").to_i.should == 5.hours.from_now.to_i
  end

  it "should detect the days" do
    EmailParser::IncrementalTime.parse("2days@sorad.cc").to_i.should == 2.days.from_now.to_i
  end

  it "should detect the days (complex)" do
    email = "5d@sorad.cc"
    EmailParser::IncrementalTime.parse(email).to_i.should == 5.days.from_now.to_i
  end

  it "should detect the weeks" do
    EmailParser::IncrementalTime.parse("2weeks@sorad.cc").to_i.should == 2.weeks.from_now.to_i
  end

  it "should detect the weeks (complex)" do
    EmailParser::IncrementalTime.parse("5w@sorad.cc").to_i.should == 5.weeks.from_now.to_i
  end

  it "should detect the months" do
    EmailParser::IncrementalTime.parse("2months@sorad.cc").to_i.should == 2.months.from_now.to_i || 2.months.from_now.to_i + 1
  end

  it "should detect the months (complex)" do
    EmailParser::IncrementalTime.parse("5mo@sorad.cc").to_i.should == 5.months.from_now.to_i
  end

  it "should detect the years" do
    EmailParser::IncrementalTime.parse("2years@sorad.cc").to_i.should == 2.years.from_now.to_i
  end

  it "should detect the years (complex)" do
    EmailParser::IncrementalTime.parse("5y@sorad.cc").to_i.should == 5.years.from_now.to_i
  end

  it "should detect everything" do
    email = "2years3months12days23hours1minute@sorad.cc"
    EmailParser::IncrementalTime.parse(email).to_i.should == (2.years + 3.months + 12.days +
                                                              23.hours + 1.minute).from_now.to_i
  end

  it "should work with composite times" do
    email = "2y3mo12d23h1m@sorad.cc"
    EmailParser::IncrementalTime.parse(email).to_i.should == (2.years + 3.months + 12.days +
                                                              23.hours + 1.minute).from_now.to_i
  end

  it "should work with a mixture of composite and non times" do
    email = "2years3mo12days23h1min@sorad.cc"
    EmailParser::IncrementalTime.parse(email).to_i.should == (2.years + 3.months + 12.days +
                                                              23.hours + 1.minute).from_now.to_i
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
    email = "1d1mo1y@sorad.cc"
    EmailParser::IncrementalTime.parse(email).to_i.should == Time.parse('31-04-2012').to_i
  end
end
