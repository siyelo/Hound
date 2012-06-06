require 'interval_parser'

describe IntervalParser do
  it "parses adverb addresses (defaulting to 8am)" do
    Time.zone = "Harare"
    IntervalParser.parse('tomorrow').should == (Time.now.utc + 1.day).change(hour: 8)
  end

  it "parses incremental addresses" do
    IntervalParser.parse('2d').to_i.should == (Time.now + 2.days).to_i
  end

  it "parses calendar addresses w/o times: defaults to 8am" do
    IntervalParser.parse('12Nov2013').should == DateTime.parse('12Nov2013 08:00')
  end

  it "parses full month names" do
    IntervalParser.parse('12November2013').should == DateTime.parse('12Nov2013 08:00')
  end

  it "parses adverbs and times" do
    IntervalParser.parse('tomorrow1030pm').should == (Time.now.utc + 1.day).change(hour: 22, min: 30)
  end

  it "parses times" do
    IntervalParser.parse('1030pm').should == (Time.now.utc).change(hour: 22, min: 30)
  end

  it "returns nil or barfs on bad local parts" do
    lambda do
      IntervalParser.parse('99Apr999 aa:00')
    end.should raise_exception ArgumentError
    IntervalParser.parse('pimping').should be_nil
  end

end
