require 'spec_helper'

describe ReminderCreationService do
  before :each do
    @now = Time.now.utc
    @mail = Mail.new from: 'a@a.com', to: '1h@hound.cc'
    @service = ReminderCreationService.new()
  end
  
  it "finds or.creates a user", type: 'integration' do
    @service.create! @mail
    User.first.email.should == 'a@a.com'
  end
  
  it "saves a reminder for each Hound Address in the to/cc/bcc", type: 'integration' do
    @mail.to = '1h@hound.cc'
    user = Factory :user
    User.stub(:find_or_invite!).and_return user
    Reminder.should_receive(:new).with(send_at: @now + 1.hour, user: user)
    Reminder.should_receive(:save!)
    @service.create! @mail
  end
  
  it "should save the Mail", type: 'integration' do
    user = Factory :user
    User.stub(:find_or_invite!).and_return user
    FetchedMail.should_receive(:new).with(user: user)
    FetchedMail.should_receive(:from_mail).with(@mail)
    FetchedMail.should_receive(:save!)
    @service.create! @mail
  end

end
