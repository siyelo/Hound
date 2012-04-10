require 'email_list'

describe EmailList do
  it "can create a list from a single email address" do
    EmailList.new('1@abc.com').should == ['1@abc.com']
  end

  it "can create a list from a multi email array" do
    EmailList.new(['1@abc.com', '2@abc.com']).should == ['1@abc.com', '2@abc.com']
  end

  it "can create a list from a multi email address string" do
    EmailList.new('1@abc.com, 2@abc.com').should == ['1@abc.com', '2@abc.com']
  end

  it "can handle nil" do
    EmailList.new(nil).should == []
  end

  it "can handle blank spaces" do
    EmailList.new('   ').should == []
  end
end
