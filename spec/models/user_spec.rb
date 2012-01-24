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
    end

    context "new users" do
      before :each do
        Mail.stub(:all).and_return([Mail.new(from: 'pimp@macdaddy.yo',
                                             to: '2days@radmeet.cc',
                                             subject: 'test', date: DateTime.now)])
        FetchMailWorker.perform
      end

      it "should get confirmation that a reminder has been processed (new users receive them automatically)" do
        Reminder.all.count.should == 1 #sanity
        SendConfirmationWorker.should have_queue_size_of(1)
        SendConfirmationWorker.perform(Reminder.last.id)
        User.all.count.should == 1
        User.first.timezone.should == "+02:00"

        #only 2 because one is confirmation signup email and the other is the confirmation
        #email - the reminder email is not included in this test
        unread_emails_for('pimp@macdaddy.yo').size.should >= parse_email_count(2)
      end
    end

    context "existing users" do
      before :each do
        @user = Factory :user, email: 'pimp@macdaddy.yo', confirmation_email: false
        Mail.stub(:all).and_return([Mail.new(from: 'pimp@macdaddy.yo',
                                             to: '2days@radmeet.cc',
                                             subject: 'test', date: DateTime.now)])
        FetchMailWorker.perform
      end

      it "should not receive an email if the user has disabled that in their settings" do
        Reminder.all.count.should == 1 #sanity
        SendConfirmationWorker.should have_queue_size_of(0)
        #0 emails because there is no confirmation signup email nor is there a confirmation reminder
        #email - the reminder email is not included in this test
        unread_emails_for('pimp@macdaddy.yo').size.should >= parse_email_count(0)
      end
    end

  end

  describe 'invitation emails' do
    before(:each) do
      reset_mailer
      Mail.stub(:all).and_return([Mail.new(from: 'sachin@siyelo.com',
                                           to: '2days@mailshotbot.com',
                                           subject: 'test', date: DateTime.now)])
    end

    it "should be sent to user who isn't already registered" do
      FetchMailWorker.perform
      Reminder.all.count.should == 1
      User.all.count.should == 1
      User.first.timezone.should == "+02:00"
      unread_emails_for('sachin@siyelo.com').size.should >= parse_email_count(1)
    end

    it 'should not be sent to a user that exists' do
      user = Factory(:user, :email => 'sachin@siyelo.com')
      FetchMailWorker.perform
      Reminder.all.count.should == 1
      unread_emails_for('sachin@siyelo.com').size.should == parse_email_count(0)
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
end
