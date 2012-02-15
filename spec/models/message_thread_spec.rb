require 'spec_helper'

describe MessageThread do
  it "should return the to: address of all reminders in thread" do
    message = Factory :message_thread
    reminder1 = Factory :reminder, message_thread: message, sent_to: '5min@hound.cc'
    reminder2 = Factory :reminder, message_thread: message, sent_to: '2min@hound.cc'
    message.hound_recipients.should == [reminder1.sent_to, reminder2.sent_to]
  end
end
