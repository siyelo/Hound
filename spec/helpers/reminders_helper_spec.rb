require 'spec_helper'

describe RemindersHelper do
  describe "#recipient_addresses" do
    it "only returns addresses that aren't hound addresses" do
      fm = mock FetchedMail
      r = mock Reminder, fetched_mail: fm
      fm.should_receive(:all_addresses).once.and_return(["1d@hound.cc", "bam@pew.com"])
      helper.recipient_addresses(r).should == ["bam@pew.com"]
    end
  end
end
