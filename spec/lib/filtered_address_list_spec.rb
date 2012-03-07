require 'spec_helper'

describe FilteredAddressList do
  it "filters out hound addresses that already exist in parent message" do
    parent = Factory :fetched_mail, message_id: '123', to: ['1d@hound.cc']
    reply = Factory.build :fetched_mail, in_reply_to: '123', to: ['1d@hound.cc']
    FilteredAddressList.new(reply).should == []
  end
end

