require 'spec_helper'

describe DateTime do
  it "parses adverb addresses (defaulting to 8am)" do
    #DateTime.parse_email('tomorrow@hound.cc').to_i.should == (DateTime.now.utc + 1.day).to_i
    DateTime.parse_email('tomorrow@hound.cc').should == (DateTime.now.utc + 1.day).change(hour: 8)
  end

  it "parses incremental addresses" do
    DateTime.parse_email('2d@hound.cc').to_i.should == (DateTime.now.utc + 2.days).to_i
  end

  # it "parses calendar addresses with times" do
  #   DateTime.parse_email('12Nov2013-1400@hound.cc').to_i.should == DateTime.parse('12Nov20131400').to_i
  # end

  it "parses calendar addresses w/o times: defaults to 8am" do
    DateTime.parse_email('12Nov2013@hound.cc').should == DateTime.parse('12Nov2013 08:00')
  end

  it "parses full month names" do
    DateTime.parse_email('12November2013@hound.cc').should == DateTime.parse('12Nov2013 08:00')
  end
  
  it "barfs on bad local parts" do
    lambda do
      DateTime.parse_email('pimpin@hound.cc')
    end.should raise_exception ArgumentError
  end

end
