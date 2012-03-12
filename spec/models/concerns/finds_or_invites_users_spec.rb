require 'spec_helper'

describe User do #FindsOrInvitesUsers
  before :each do
    @mail = Mail.new from: '1@1.com', date: Time.now.utc
  end

  it "should find a user by alias" do
    User.should_receive(:find_by_email_or_alias).with('1@1.com').twice
    User.find_or_invite!(@mail)
  end

  it "should create a user if no account found" do
    user = double('user')
    user.should_receive(:new).with(email: '1@1.com', timezone: 'Casablanca')
    user.should_receive(:invite!)
    User.find_or_invite!(@mail)
  end

  it "should not create a user the account was found" do
    user = Factory.build :user
    User.stub(:find_by_email_or_alias).and_return(user)
    user.should_not_receive(:invite!)
    User.find_or_invite!(@mail)
  end

  it "should not throw an exception if mail.from is nil", type: 'integration' do
    @mail.from = nil
    lambda do
      User.find_or_invite!(@mail)
    end.should_not raise_exception(NoMethodError)
  end

  it "should not throw an exception if mail.date is nil", type: 'integration' do
    @mail.date = nil
    lambda do
      User.find_or_invite!(@mail)
    end.should_not raise_exception(NoMethodError)
  end

  it "should throw an exception if inviting nil user (mail.from)", type: 'integration' do
    @mail.from = nil
    lambda do
      User.find_or_invite!(@mail)
    end.should raise_exception
  end

  it "should set time zone to UTC if email date is nil", type: 'integration' do
    @mail.date = nil
    user = User.find_or_invite!(@mail)
    user.timezone.should == 'Casablanca'
  end


end
