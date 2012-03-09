require 'spec_helper'

describe ReminderCreationService do
  before :each do
    @now = Time.now.utc
    @mail = Mail.new from: 'a@a.com', date: @now
    @service = ReminderCreationService.new()
  end

  it "finds or.creates a user" do
    User.should_receive(:find_or_invite!).with(@mail) #TODO deprecate
    @service.create! @mail
  end

  it "saves a reminder for each Hound Address in the to/cc/bcc" do
    @mail.stub(:to).and_return '1h@hound.cc'
    Reminder.should_receive(:new).with(send_at: @now + 1.hour)
    Reminder.should_receive(:save!)
    @service.create! @mail
  end

  it "should save the Mail" do
    FetchedMail.should_receive(:new).with(@mail)
    FetchedMail.should_receive(:save!)
    @service.create! @mail
  end

end
