require 'spec_helper'

describe FetchedMail do
  it { should belong_to :user }
  it { should have_many :reminders }

  it { should validate_presence_of :from}
  it { should validate_presence_of :to}
  it { should validate_presence_of :user }

  #optional email fields
  it { should_not validate_presence_of :body}
  it { should_not validate_presence_of :cc}
  it { should_not validate_presence_of :bcc}
  it { should_not validate_presence_of :subject}

  it "should validate unique messsage ids" do
    FactoryGirl.create :fetched_mail
    FetchedMail.new.should validate_uniqueness_of( :message_id )
  end

  describe "body" do
    it "saves body with bad encoding" do
      fm = FactoryGirl.create :fetched_mail
      lambda do
        #note rspec barfs if this spec fails!
        fm.body = "\xA0bad encoding \xA0/"
        fm.save!
      end.should_not raise_exception
      fm.reload
      fm.body.valid_encoding?.should be_true
    end
  end

  describe "#create_from_mail!" do
    before :each do
      @user = FactoryGirl.create :user
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

    it "creates an email from a Mail::Message object" do
      @email.to.should == ['1d@hound.cc']
      @email.from.should == 'sachin@siyelo.com'
      @email.subject.should == 'email subject'
      @email.message_id.should == '12345'
      @email.in_reply_to.should == '1111'
    end

    it "saves multiple to/cc/bcc addresses" do
      @message.to << 'frank@furter.com'
      fm = FetchedMail.create_from_mail!(@message, FactoryGirl.create(:user))
      fm.to.should == ['1d@hound.cc', 'frank@furter.com']
      FetchedMail.first.to.should == ['1d@hound.cc', 'frank@furter.com']
    end

    it "extracts the html part of the message as the body" do
      @message.html_part do
        content_type 'text/html; charset=UTF-8'
        body '<h1>This is HTML</h1>'
      end
      email = FetchedMail.new
      email.from_mail(@message)
      email.body.should == "<h1>This is HTML</h1>"
    end

    describe "email fields as strings or arrays" do
      it "returns the cc's or an empty array" do
        @email.cc.should == []
      end

      it "returns the bcc's or an empty array" do
        @email.bcc.should == []
      end

      it "accepts an array of cc's and return an array" do
        @email.cc = ['cc@example.com']
        @email.user = FactoryGirl.create :user
        @email.save!
        @email.reload
        @email.cc.should == ['cc@example.com']
      end

      it "accepts a cc as a string" do
        @email.cc = 'cc@example.com'
        @email.user = FactoryGirl.create :user
        lambda do
          @email.save!
        end.should_not raise_exception ActiveRecord::SerializationTypeMismatch
      end

      it "returns an empty array if cc is nil" do
        @email.cc = nil
        @email.user = FactoryGirl.create :user
        @email.save!
        @email.reload
        @email.cc.should == []
      end

      it "allows multiple cc's to be created with a string" do
        @email.cc = 'cc@abc.com, cc1@abc.com'
        @email.user = FactoryGirl.create :user
        lambda do
          @email.save!
        end.should_not raise_exception ActiveRecord::SerializationTypeMismatch
      end
    end

    it "extracts the text part of the message as the body if there is not HTML" do
      @email.body.should == "This is plain text"
    end
  end

  describe "#parent" do
    before :each do
      @parent = FactoryGirl.create :fetched_mail, message_id: '123'
    end

    it "finds no parent" do
      @parent.parent.should == nil
    end

    it "matches nil parents for nil reply ids" do
      @parent.message_id = nil
      @parent.save!
      @parent.parent.should == nil
    end

    it "finds its parent by message_id" do
      @mail = Mail.new in_reply_to: '123'
      @child = FetchedMail.new
      @child.from_mail(@mail)
      @child.parent.should == @parent
    end
  end

  it "#all_addresses returns all addresses" do
    mail = FactoryGirl.create :fetched_mail, to: ['1d@hound.cc'], cc: ['1@1.com'], bcc: ['2@2.com']
    mail.all_addresses.should == ['1d@hound.cc', '1@1.com', '2@2.com']
  end

  it "returns true if a hound address is in the bcc" do
    mail = FactoryGirl.create :fetched_mail, to: ['1d@hound.cc'], cc: ['1@1.com'], bcc: ['2d@hound.cc']
    mail.is_address_bcc?('2d@hound.cc').should == true
  end
end
