require 'spec_helper'

describe EmailBodyParser do

  before :each do
    @message = Mail.new
  end

  it "should extract the html part of the message as the body" do
    @message.html_part do
      content_type 'text/html; charset=UTF-8'
      body '<h1>This is HTML</h1>'
    end
    EmailBodyParser.extract_html_or_text_from_body(@message).should == "<h1>This is HTML</h1>"
  end

  it "should extract the text part of the message as the body if there is not HTML" do
    @message.text_part do
      body 'This is plain text'
    end
    EmailBodyParser.extract_html_or_text_from_body(@message).should == "This is plain text"
  end


end
