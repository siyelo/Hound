require 'spec_helper'

describe Hound::UserMerger do
  before :each do
    @user1 = Factory :user
    @user2 = Factory :user
    fetched_mail1 = Factory :fetched_mail, user: @user1
    fetched_mail2 = Factory :fetched_mail, user: @user2
    reminder1 = Factory :reminder, fetched_mail: fetched_mail1
    reminder2 = Factory :reminder, fetched_mail: fetched_mail2
    email_alias1 = Factory :email_alias, user: @user1
    email_alias2 = Factory :email_alias, user: @user2

    @merger_service = Hound::UserMerger.new
  end

  it "should assign user 2's fetched mails to user 1" do
    @user1.fetched_mails.count.should == 1
    @merger_service.perform(@user1, @user2)
    @user1.reload
    @user1.fetched_mails.count.should == 2
  end

  it "should assign user 2's reminders to user 1" do
    @user1.reminders.count.should == 1
    @merger_service.perform(@user1, @user2)
    @user1.reload
    @user1.reminders.count.should == 2
  end

  it "should create a new email alias for user 1 based on user 2's email" do
    @merger_service.perform(@user1, @user2)
    @user1.reload
    @user1.email_aliases.find_by_email(@user2.email).should_not be_nil
  end

  it "should assign user 2's email aliases to user 1" do
    @user1.email_aliases.count.should == 1
    @merger_service.perform(@user1, @user2)
    @user1.reload
    @user1.email_aliases.count.should == 3
  end

  it "should delete user 2 after merging" do
    User.count.should == 2
    @merger_service.perform(@user1, @user2)
    User.count.should == 1
    User.first.should == @user1
  end

  it "should return false if merger fails" do
    FetchedMail.any_instance.stub(:save!).and_raise ActiveRecord::StatementInvalid.new
    @merger_service.perform(@user1, @user2).should be_false
  end

  it "should rollback in the event of an error" do
    @user2.stub(:destroy).and_raise ActiveRecord::RecordInvalid.new(@user2)
    @merger_service.perform(@user1, @user2).should be_false
    @user2.reload; @user1.reload
    @user2.fetched_mails.count.should == 1
    @user1.fetched_mails.count.should == 1
  end

  it "should rollback in the event of an error" do
    @user2.stub(:destroy).and_raise ActiveRecord::StatementInvalid.new
    @merger_service.perform(@user1, @user2).should be_false
    @user2.reload; @user1.reload
    @user2.fetched_mails.count.should == 1
    @user1.fetched_mails.count.should == 1
  end
end
