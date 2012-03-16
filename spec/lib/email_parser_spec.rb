require 'email_parser'

describe EmailParser do
  it "parses adverb addresses (defaulting to 8am)" do
    Time.zone = "Harare"
    EmailParser.parse('tomorrow@hound.cc').should == (Time.zone.now + 1.day).change(hour: 8)
  end

  it "parses incremental addresses" do
    EmailParser.parse('2d@hound.cc').to_i.should == (Time.now + 2.days).to_i
  end

  it "parses calendar addresses w/o times: defaults to 8am" do
    EmailParser.parse('12Nov2013@hound.cc').should == DateTime.parse('12Nov2013 08:00')
  end

  it "parses full month names" do
    EmailParser.parse('12November2013@hound.cc').should == DateTime.parse('12Nov2013 08:00')
  end

  it "barfs on bad local parts" do
    lambda do
      EmailParser.parse('pimpin@hound.cc')
    end.should raise_exception ArgumentError
  end
end
