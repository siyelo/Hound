require 'spec_helper'

describe User do
  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
    it { should_not allow_value("blah").for(:email) }
    it { should allow_value("a@b.com").for(:email) }
    it { should_not allow_value("123").for(:password) }
    it { should allow_value("123123").for(:password) }

    context "existing record in db" do
      subject { Factory(:user) }
      it { should validate_uniqueness_of(:email).case_insensitive }
    end

    it "password & confirmation don't match" do
      user = Factory.build(:user, :password => '123456', :password_confirmation => '123')
      user.save
      user.errors.get(:password).should == ["doesn't match confirmation"]
    end

    it "password confirmation is blank" do
      user = Factory.build(:user, :password => '123456', :password_confirmation => '')
      user.save
      user.errors.get(:password).should == ["doesn't match confirmation"]
    end
  end

  describe "account status" do
    it "should return false if invitation has not been accepted" do
      user = User.invite!(email: 'a@b.com')
      user.active?.should be_false
    end

    it "should return true if invitation has been accepted" do
      user = User.invite!(email: 'a@b.com')
      User.accept_invitation!(:invitation_token => user.invitation_token,
                              :password => "password")
      user.reload
      user.active?.should be_true
    end

    it "should return true if user signed-up (was not invited)" do
      user = Factory(:user)
      user.active?.should be_true
    end
  end

  describe 'invitation emails' do
    before(:each) do
      reset_mailer
      Mail.stub(:all).and_return([Mail.new(from: 'sachin@siyelo.com',
                                           to: '2days@radmeet.cc',
                                           subject: 'test')])
    end

    it "should be sent to user who isn't already registered" do
      FetchMailWorker.perform
      Reminder.all.count.should == 1
      User.all.count.should == 1
      unread_emails_for('sachin@siyelo.com').size.should >= parse_email_count(1)
    end

    it 'should not be sent to a user that exists' do
      user = Factory(:user, :email => 'sachin@siyelo.com')
      FetchMailWorker.perform
      Reminder.all.count.should == 1
      unread_emails_for('sachin@siyelo.com').size.should == parse_email_count(0)
    end
  end
end
