require 'hound_address_list'

class FetchedMail; end

describe HoundAddressList do
  it "should accept nil" do
    mail = mock FetchedMail, all_addresses: []
    FetchedMail.stub(:new).and_return mail
    HoundAddressList.new(nil).should == []
  end

  it "extracts the hound address" do
    mail = mock FetchedMail, all_addresses: ['1d@hound.cc', 'frank@f.com']
    HoundAddressList.new(mail).should == ['1d@hound.cc']
  end

  it "extracts the hound address" do
    mail = mock FetchedMail, all_addresses: ['2d@hound.cc']
    HoundAddressList.new(mail).should == ['2d@hound.cc']
  end

  it "extracts the hound addresses when > hounds (to)" do
    mail = mock FetchedMail, all_addresses: ['1d@hound.cc', '2d@hound.cc']
    HoundAddressList.new(mail).should == ['1d@hound.cc', '2d@hound.cc']
  end

  it "extracts the hound cc addresses" do
    mail = mock FetchedMail, all_addresses: ['b@b.com', '1d@hound.cc', '2d@hound.cc', 'g@g.com']
    HoundAddressList.new(mail).should == ['1d@hound.cc', '2d@hound.cc']
  end

  it "extracts the hound bcc addresses" do
    mail = mock FetchedMail, all_addresses: ['b@b.com', '1d@hound.cc', '2d@hound.cc', 'g@g.com']
    HoundAddressList.new(mail).should == ['1d@hound.cc', '2d@hound.cc']
  end

end
