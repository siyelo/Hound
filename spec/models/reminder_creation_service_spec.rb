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
  
  it "saves one reminder if one Hound Address in the to/cc/bcc", type: 'integration' do
    @mail.to = '1h@hound.cc'
    user = Factory :user
    User.stub(:find_or_invite!).and_return user
    @service.create! @mail
    Reminder.last.send_at.to_i.should == 1.hour.from_now.to_i#.change(hour: 8)
  end
  
  it "should save the Mail", type: 'integration' do
    user = Factory :user
    User.stub(:find_or_invite!).and_return user
    @service.create! @mail
    FetchedMail.first.to.should == @mail.to
  end

end
