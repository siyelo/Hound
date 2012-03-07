require 'spec_helper'

describe EmailParser do
  it "parses adverb addresses (defaulting to 8am)" do
    EmailParser.parse('tomorrow@hound.cc').should == (DateTime.now.utc + 1.day).change(hour: 8)
  end

  it "parses incremental addresses" do
    EmailParser.parse('2d@hound.cc').to_i.should == (DateTime.now.utc + 2.days).to_i
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
