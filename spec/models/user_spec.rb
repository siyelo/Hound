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

  describe 'modify_token' do
    before :each do
      @user = Factory :user
    end

    it "exists when user is created" do
      @user.modify_token.should_not be_nil
    end

    it "should be removed after clicking the link to remove email notifications" do
      @user.toggle_confirmation_email(@user.modify_token)
      @user.modify_token.should be_nil
    end

    it "should be regenerated when confirmation email is set to true" do
      u = Factory :user, confirmation_email: false
      u.modify_token = nil; u.save
      u.confirmation_email = true
      u.save
      u.reload
      u.modify_token.should_not be_nil
    end
  end

  it 'should find a user by alias email' do
    alias_email = Factory :email_alias, email: '1@1.com'
    found = User.find_by_email_or_alias('1@1.com')
    found.should == alias_email.user
  end
end
