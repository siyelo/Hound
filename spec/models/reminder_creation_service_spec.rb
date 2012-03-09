require 'spec_helper'

describe ReminderCreationService do
  before :each do
    @mail = stub :Mail, from: 'a@a.com', date: Time.zone.now
    User.stub(:find_or_invite).and_return(Factory.build :user)
    debugger
    @fetched_mail = Factory.build :fetched_mail
    FetchedMail.stub(:new).and_return(@fetched_mail)
    @service = ReminderCreationService.new()
  end

  it "finds or creates a user" do
    User.should_receive(:find_or_invite).with(@mail) #TODO deprecate
    @service.create @mail
  end

  it "should build a FetchedMail" do
    FetchedMail.should_receive(:new).with(@mail)
    @service.create @mail
  end


  #t should save the FetchedMail if >= 1 hound address

end
