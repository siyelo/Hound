require 'spec_helper'

describe FetchedMail do
  it { should belong_to :user }

  it { should validate_presence_of :from}
  it { should validate_presence_of :to}
  it { should validate_presence_of :user }

  #optional email fields
  it { should_not validate_presence_of :body}
  it { should_not validate_presence_of :cc}
  it { should_not validate_presence_of :bcc}
  it { should_not validate_presence_of :subject}

  it "should validate unique messsage ids" do
    Factory :fetched_mail
    FetchedMail.new.should validate_uniqueness_of( :message_id )
  end

  describe "#create_from_mail!" do
    before :each do
      @user = Factory :user
    end

    it "should create from a Mail object" do
      @message = Mail.new do
        to '1d@hound.cc'
        from 'sachin@siyelo.com'
      end
      FetchedMail.create_from_mail!(@message, @user).id.should_not be_nil
    end
  end

  describe "fields" do
    before :each do
      @message = Mail.new do
        to '1d@hound.cc'
        from 'sachin@siyelo.com'
        subject 'email subject'
        date Time.zone.now
        text_part do
          body 'This is plain text'
        end
        message_id '12345'
        in_reply_to '1111'
      end
      @email = FetchedMail.new
      @email.from_mail(@message)
    end

    it "should create an email from a Mail::Message object" do
      @email.to.should == ['1d@hound.cc']
      @email.from.should == 'sachin@siyelo.com'
      @email.subject.should == 'email subject'
      @email.message_id.should == '12345'
      @email.in_reply_to.should == '1111'
    end

    it "should save multiple to/cc/bcc addresses" do
      @message.to << 'frank@furter.com'
      fm = FetchedMail.create_from_mail!(@message, Factory(:user))
      fm.to.should == ['1d@hound.cc', 'frank@furter.com']
      FetchedMail.first.to.should == ['1d@hound.cc', 'frank@furter.com']
    end

    it "should extract the html part of the message as the body" do
      @message.html_part do
        content_type 'text/html; charset=UTF-8'
        body '<h1>This is HTML</h1>'
      end
      email = FetchedMail.new
      email.from_mail(@message)
      email.body.should == "<h1>This is HTML</h1>"
    end

    describe "email fields as strings or arrays" do
      it "should return the cc's or an empty array" do
        @email.cc.should == []
      end

      it "should return the bcc's or an empty array" do
        @email.bcc.should == []
      end

      it "should accept an array of cc's and return an array" do
        @email.cc = ['cc@example.com']
        @email.user = Factory :user
        @email.save!
        @email.reload
        @email.cc.should == ['cc@example.com']
      end

      it "should not accept a cc as a string" do
        @email.cc = 'cc@example.com'
        @email.user = Factory :user
        lambda do
          @email.save!
        end.should raise_exception ActiveRecord::SerializationTypeMismatch
      end

      it "should return an empty array if cc is nil" do
        @email.cc = nil
        @email.user = Factory :user
        @email.save!
        @email.reload
        @email.cc.should == []
      end

      it "should not allow multiple cc's to be created with a string" do
        @email.cc = 'cc@abc.com, cc1@abc.com'
        @email.user = Factory :user
        lambda do
          @email.save!
        end.should raise_exception ActiveRecord::SerializationTypeMismatch
      end
    end

    it "should extract the text part of the message as the body if there is not HTML" do
      @email.body.should == "This is plain text"
    end
  end


  describe "#parent" do
    before :each do
      @parent = Factory :fetched_mail, message_id: '123'
    end

    it "should find no parent" do
      @parent.parent.should == nil
    end

    it "should not match nil parents for nil reply ids" do
      @parent.message_id = nil
      @parent.save!
      @parent.parent.should == nil
    end

    it "should find its parent by message_id" do
      @mail = Mail.new in_reply_to: '123'
      @child = FetchedMail.new
      @child.from_mail(@mail)
      @child.parent.should == @parent
    end
  end
end
