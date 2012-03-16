require 'token'

describe Token do
  it "should create a 40 char token by default" do
    t = Token.new
    t.length.should == 40
  end

  it "should create a hex string" do
    t = Token.new
    t.should =~ /^[0-9A-Fa-f]+$/
  end

  it "should create a random string" do
    t = Token.new
    t1 = Token.new
    t.should_not == t1
  end

  it "should allow for <40 chars" do
    t = Token.new(8)
    t.length.should == 8
  end
end
