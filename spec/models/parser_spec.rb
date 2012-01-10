require 'spec_helper'

describe Parser do
  describe "parse addresses" do
    before :each do
      @email = "2years3months12days23hours1minute@radmeet.cc"
    end

    it "should detect the days" do
      Parser.parse_email(@email).should == "icecream"
    end
  end
end
