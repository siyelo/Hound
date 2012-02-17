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
      user.errors[:email].should include 'is not unique'
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

  describe "confirmation emails" do
    before(:each) do
      ResqueSpec.reset!
      reset_mailer
      Timecop.return

      Mail.stub(:all).and_return([Mail.new(from: 'pimp@macdaddy.yo',
                                           to: '2days@hound.cc',
                                           subject: 'test', date: DateTime.now)])
    end

    context "existing users" do
      it "should receive a confirmation email" do
        user = Factory :user, email: 'pimp@macdaddy.yo'
        FetchMailWorker.perform
        Reminder.all.count.should == 1 #sanity
        SendConfirmationWorker.should have_queue_size_of(1)
        SendConfirmationWorker.perform(Reminder.last.id)
        unread_emails_for('pimp@macdaddy.yo').size.should == parse_email_count(1)
      end

      it "should not receive an email if the user has disabled that in their settings" do
        user = Factory :user, email: 'pimp@macdaddy.yo', confirmation_email: false
        FetchMailWorker.perform
        Reminder.all.count.should == 1 #sanity
        SendConfirmationWorker.should have_queue_size_of(0)
      end
    end

    context "new users" do
      it "should send an invitation to new users" do
        FetchMailWorker.perform
        Reminder.all.count.should == 1 #sanity
        SendConfirmationWorker.should have_queue_size_of(1)
        SendConfirmationWorker.perform(Reminder.last.id)
        unread_emails_for('pimp@macdaddy.yo').size.should == parse_email_count(1)
      end
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

  describe 'find or invite user' do
    it 'should find user by primary email' do
      user = Factory :user, email: '1@1.com'
      found = User.find_or_invite(Mail.new(from: '1@1.com', date: DateTime.now))
      found.should == user
    end

    it 'should find a user by alias email' do
      alias_email = Factory :email_alias, email: '1@1.com'
      found = User.find_or_invite(Mail.new(from: '1@1.com', date: DateTime.now))
      found.should == alias_email.user
    end

    it 'should invite a user if they are not found' do
      found = User.find_or_invite(Mail.new(from: '1@1.com', date: DateTime.now))
      found.active?.should be_false
    end
  end
end
