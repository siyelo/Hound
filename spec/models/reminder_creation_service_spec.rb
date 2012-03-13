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
  
  it "creates one reminder per Hound Address (single)", type: 'integration' do
    @mail.to = '1h@hound.cc'
    user = Factory :user
    User.stub(:find_or_invite!).and_return user
    @service.create! @mail
    Reminder.last.send_at.to_i.should == 1.hour.from_now.to_i#.change(hour: 8)
  end
  
  describe "multiple hound addresses" do 
    before :each do
      @mail.to = '1h@hound.cc, 2h@hound.cc'
      @user = Factory :user
      User.stub(:find_or_invite!).and_return @user
      @service.create! @mail
    end
  
    it "creates one reminder per Hound Address (multiple)", type: 'integration' do
      Reminder.all.size.should == 2
    end

    it "creates one reminder per Hound Address (multiple)", type: 'integration' do
      Reminder.first.send_at.to_i.should == 1.hour.from_now.to_i#.change(hour: 8)
      Reminder.last.send_at.to_i.should == 2.hour.from_now.to_i#.change(hour: 8)
    end
  end
  
  it "should save the Mail", type: 'integration' do
    user = Factory :user
    User.stub(:find_or_invite!).and_return user
    @service.create! @mail
    FetchedMail.first.to.should == @mail.to
  end

end
