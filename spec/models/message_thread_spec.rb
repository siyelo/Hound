require 'spec_helper'

describe MessageThread do
  it "should return the to: address of all reminders in thread" do
    message = Factory :message_thread
    reminder1 = Factory :reminder, message_thread: message, sent_to: '5min@hound.cc'
    reminder2 = Factory :reminder, message_thread: message, sent_to: '2min@hound.cc'
    message.hound_recipients.should == [reminder1.sent_to, reminder2.sent_to]
  end

  context 'last leave' do
    it "should return the last leave if there are children" do
      parent = Factory :message_thread
      child = Factory :message_thread, parent: parent
      grandchild1 = Factory :message_thread, parent: child
      grandchild2 = Factory :message_thread, parent: child, message_id: 'blumpkin'
      parent.reload
      parent.last_message_id.should == 'blumpkin'
    end

    it "should return the root message id if there are no children" do
      parent = Factory :message_thread
      parent.last_message_id.should == parent.message_id
    end
  end
end
