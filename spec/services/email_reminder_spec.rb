require 'spec_helper'

describe Services::EmailReminder do
  it "should create a new reminder" do
    rs = Services::EmailReminder.new(Mail.new(from: 'g@g.com', to: '1d@hound.cc',
                                     cc: 'cc@c.com', subject: 's', body: 'b',
                                     message_id: '531', date: DateTime.now))
    rs.from.should == 'g@g.com'
    rs.to.should == '1d@hound.cc'
    rs.cc.should == 'cc@c.com'
    rs.subject.should == 's'
    rs.body.should == 'b'
    rs.message_id.should == '531'
  end

  it "should match an existing message thread" do
    pending
  end

  it "should create one reminder per hound.cc address in the mail" do
    pending
  end

  it "should parse each hound.cc address for a correct date" do
    pending
  end

  it "should find or invite a user" do
    pending
  end

  it "should deliver an error notification if the hound address is invalid" do
    pending
  end

end
