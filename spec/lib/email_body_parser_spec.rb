require 'email_body_parser'
require 'ostruct'

describe EmailBodyParser do
  let (:message) {stub}

  it "should extract the html part of the message as the body" do
    html = OpenStruct.new
    body = OpenStruct.new
    body.decoded = '<h1>This is HTML</h1>'
    html.body = body
    message.stub(:html_part).and_return html
    EmailBodyParser.extract_html_or_text_from_body(message).should == "<h1>This is HTML</h1>"
  end

  describe "text emails" do
    before :each do
      @body = OpenStruct.new
      @body.decoded = 'This is plain text'
      message.stub(:html_part).and_return nil
    end

    it "should extract the text part" do
      text = OpenStruct.new
      text.body = @body
      message.stub(:text_part).and_return text
      message.stub(:multipart?).and_return true
      EmailBodyParser.extract_html_or_text_from_body(message).should == "This is plain text"
    end

    it "should extract the decoded body if not multipart" do
      message.stub(:body).and_return @body
      message.stub(:multipart?).and_return false
      EmailBodyParser.extract_html_or_text_from_body(message).should == "This is plain text"
    end
  end

end
