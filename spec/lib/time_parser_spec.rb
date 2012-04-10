require 'time_parser'

describe TimeParser do
  it "parses adverb addresses (defaulting to 8am)" do
    Time.zone = "Harare"
    TimeParser.parse('tomorrow').should == (Time.now.utc + 1.day).change(hour: 8)
  end

  it "parses incremental addresses" do
    TimeParser.parse('2d').to_i.should == (Time.now + 2.days).to_i
  end

  it "parses calendar addresses w/o times: defaults to 8am" do
    TimeParser.parse('12Nov2013').should == DateTime.parse('12Nov2013 08:00')
  end

  it "parses full month names" do
    TimeParser.parse('12November2013').should == DateTime.parse('12Nov2013 08:00')
  end

  it "barfs on bad local parts" do
    lambda do
      TimeParser.parse('pimpin')
    end.should raise_exception ArgumentError
  end
end
