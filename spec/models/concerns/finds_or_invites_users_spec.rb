require 'spec_helper'

describe User do #FindsOrInvitesUsers
  before :each do
    @mail = Mail.new from: '1@1.com', date: Time.now.utc
  end
  it "should find a user by alias" do
    User.should_receive(:find_by_email_or_alias).with('1@1.com')
    User.find_or_invite!(@mail)
  end

  it "should create a user if no account found" do
    User.stub(:find_by_email_or_alias).and_return nil.as_null_object
    User.should_receive(:invite!).with(email: '1@1.com', timezone: 'Casablanca')
    User.find_or_invite!(@mail)
  end

  it "should not create a user the account was found" do
    User.stub(:find_by_email_or_alias).and_return(Factory.build :user)
    User.should_not_receive(:invite!)
    User.find_or_invite!(@mail)
  end

end
