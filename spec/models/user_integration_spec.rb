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
    it { should allow_mass_assignment_of :email }
    it { should allow_mass_assignment_of :password }
    it { should allow_mass_assignment_of :password_confirmation }
    it { should allow_mass_assignment_of :remember_me }
    it { should allow_mass_assignment_of :timezone }
    it { should allow_mass_assignment_of :confirmation_email }
    it { should allow_mass_assignment_of :modify_token }

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
    it "returns false if invitation has not been accepted" do
      # invite! is not used in our app, but we use it for test convenience here
      user = User.invite!(email: 'a@b.com', timezone: "+02:00") do |u|
        u.skip_invitation = true
      end
      user.active?.should be_false
    end

    it "returns true if invitation has been accepted" do
      user = User.invite!(email: 'a@b.com', timezone: "+02:00") do |u|
        u.skip_invitation = true
      end
      User.accept_invitation!(invitation_token: user.invitation_token,
                              password: "password")
      user.reload
      user.active?.should be_true
    end

    it "returns true when user signed up themselves (was not invited)" do
      user = Factory.build(:user)
      user.active?.should be_true
    end
  end

  describe '#disable_confirmation_emails' do
    let (:user) { Factory :user }

    it "modify token exists when user is created" do
      user.modify_token.should_not be_nil
    end

    it "can remove modify token" do
      user.disable_confirmation_emails
      user.modify_token.should be_nil
    end

    it "can change confirmation email" do
      user.disable_confirmation_emails
      user.reload.confirmation_email.should be_false
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

  describe 'find_and_validate_password' do
    let (:user) { Factory :user }

    it "returns the user if the password is valid" do
      User.find_and_validate_password(user.email, 'testing').should == user
    end

    it "returns nil if the user is not found" do
      User.find_and_validate_password('123@igi.com', '123').should be_nil
    end

    it "returns nil if the password is not valid" do
      User.find_and_validate_password(user.email, '123').should be_nil
    end
  end
end
