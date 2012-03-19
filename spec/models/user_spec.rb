require 'spec_helper'

describe User do
  describe "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of(:timezone) }
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

    it 'should validate uniqueness of email across aliases' do
      alias_email = Factory :email_alias, email: 'batman@gotham.com'
      user = Factory.build :user, email: 'batman@gotham.com'
      user.valid?.should be_false
      user.errors[:email].should include 'is already registered'
    end
  end

  describe "account status" do
    it "should return false if invitation has not been accepted" do
      user = User.invite!(email: 'a@b.com', timezone: "+02:00")
      user.active?.should be_false
    end

    it "should return true if invitation has been accepted" do
      user = User.invite!(email: 'a@b.com', timezone: "+02:00")
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

  describe '#disable_confirmation_emails' do
    let (:user) { Factory :user }

    it "modify token exists when user is created" do
      user.modify_token.should_not be_nil
    end

    it "can remove modify token" do
      user.disable_confirmation_emails(user.modify_token)
      user.modify_token.should be_nil
    end

    it "cannot remove modify token if token is invalid" do
      user.disable_confirmation_emails(nil)
      user.modify_token.should_not be_nil
    end

    it "can change confirmation email" do
      user.disable_confirmation_emails(user.modify_token)
      user.reload.confirmation_email.should be_false
    end

    it "cannot change confirmation email if token is invalid" do
      user.disable_confirmation_emails(nil)
      user.reload.confirmation_email.should be_true
    end

    it "should be regenerated when confirmation email is set to true" do
      user.modify_token = nil
      user.save

      user.confirmation_email = true
      user.save
      user.reload
      user.modify_token.should_not be_nil
    end
  end

end
