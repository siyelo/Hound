require 'spec_helper'

describe HoundAddressList do
  it "should accept nil" do
    HoundAddressList.new(nil).should == []
  end

  context "one hound (to) address" do
    before :each do
      @mail = Factory.build :fetched_mail, to: '1d@hound.cc, frank@f.com'
    end
    
    it "extracts the hound address" do
      HoundAddressList.new(@mail).should == ['1d@hound.cc']
    end
    
    it "extracts the hound address" do
      @mail.to = '2d@hound.cc' 
      HoundAddressList.new(@mail).should == ['2d@hound.cc']
    end
  end
  
  it "extracts the hound addresses when > hounds (to)" do
    @mail = Factory.build :fetched_mail, to: '1d@hound.cc, 2d@hound.cc'
    HoundAddressList.new(@mail).should == ['1d@hound.cc', '2d@hound.cc']
  end

  it "extracts the hound cc addresses" do
    @mail = Factory.build :fetched_mail, cc: '1d@hound.cc, 2d@hound.cc, g@g.com'
    HoundAddressList.new(@mail).should == ['1d@hound.cc', '2d@hound.cc']
  end

  it "extracts the hound bcc addresses" do
    @mail = Factory.build :fetched_mail, bcc: '1d@hound.cc, 2d@hound.cc, g@g.com'
    HoundAddressList.new(@mail).should == ['1d@hound.cc', '2d@hound.cc']
  end

end
