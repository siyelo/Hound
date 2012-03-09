require 'spec_helper'

describe FetchedMail do

  before :each do
    @message = Mail.new do
      to '1d@hound.cc'
      from 'sachin@siyelo.com'
      subject 'Reminder subject'
      date Time.zone.now
      text_part do
        body 'This is plain text'
      end
    end
  end

  it "should create an email from a Mail::Message object" do
    email = FetchedMail.new(@message)
    email.to.should == ['1d@hound.cc']
    email.from.should == 'sachin@siyelo.com'
    email.subject.should == 'Reminder subject'
  end

  it "should extract the html part of the message as the body" do
    @message.html_part do
      content_type 'text/html; charset=UTF-8'
      body '<h1>This is HTML</h1>'
    end

    email = FetchedMail.new(@message)
    email.body.should == "<h1>This is HTML</h1>"
  end

  it "should return the cc's or an empty array" do
    email = FetchedMail.new(@message)
    email.cc.should == []

    @message.cc = 't@t.com'
    email = FetchedMail.new(@message)
    email.cc.should == ['t@t.com']
  end

  it "should return the bcc's or an empty array" do
    email = FetchedMail.new(@message)
    email.bcc.should == []

    @message.bcc = 't@t.com'
    email = FetchedMail.new(@message)
    email.bcc.should == ['t@t.com']
  end

  it "should extract the text part of the message as the body if there is not HTML" do
    email = FetchedMail.new(@message)
    email.body.should == "This is plain text"
  end

  it "should return all the @hound email addresses" do
    @message.cc = 'tomorrow@hound.cc'
    email = FetchedMail.new(@message)
    email.to_hound.should == ['1d@hound.cc', 'tomorrow@hound.cc']
  end

  it "should return all the non-@hound email addresses" do
    @message.cc = 'maybe@tomorrow.cc'
    email = FetchedMail.new(@message)
    email.not_to_hound.should == ['maybe@tomorrow.cc', 'sachin@siyelo.com']
  end

  it "should add the message to an existing message thread" do
    pending  #MOVE THIS OUT
    mt = MessageThread.new message_id: '1'
    MessageThread.stub(:find_by_message_id).with('1').and_return(mt)
    @message.in_reply_to = '1'
    email = FetchedMail.new(@message)
    email.message_thread.parent.should == mt
  end

  it "should create a new message thread if existing thread is not found" do
    pending #MOVE OUT
    MessageThread.stub(:find_by_message_id).with('1').and_return(nil.as_null_object)
    @message.in_reply_to = '1'
    email = FetchedMail.new(@message)
    email.message_thread.parent.should be_nil
  end

  it "should not create a new reminder if email is reply to thread
      and hound addresses haven't changed" do
    pending
    MessageThread.stub(:find_by_message_id).with('1').and_return(nil.as_null_object)

    @message.message_id = '1'
    parent_email = FetchedMail.new(@message)

    @message.in_reply_to = '1'
    @message.message_id = '2'
    email = FetchedMail.new(@message)

    email.create_new_reminder?.should be_nil
  end

  it "should find an existing user from the message's from address" do

  end

  it "should build a new user from the message from address and timezone" do

  end

end
