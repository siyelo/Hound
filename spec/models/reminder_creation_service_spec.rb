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
    Reminder.last.send_at.to_i.should == 1.hour.from_now.to_i
  end
  
  describe "multiple hound addresses" do 
    before :each do
      @mail.to = '1h@hound.cc, 2h@hound.cc'
      @user = Factory :user
      User.stub(:find_or_invite!).and_return @user
    end
  
    it "creates one reminder per Hound Address (multiple)", type: 'integration' do
      @service.create! @mail
      Reminder.all.size.should == 2
    end

    it "creates one reminder per Hound Address (multiple)", type: 'integration' do
      @service.create! @mail
      Reminder.first.send_at.to_i.should == 1.hour.from_now.to_i
      Reminder.last.send_at.to_i.should == 2.hour.from_now.to_i
    end

    it "accepts hound as cc" do
      @mail.to = 'frank@furter.com'
      @mail.cc = '1h@hound.cc'
      @service.create! @mail
      Reminder.all.size.should == 1
    end
    
    it "accepts hound as bcc" do
      @mail.to = 'frank@furter.com'
      @mail.bcc = '1h@hound.cc'
      @service.create! @mail
      Reminder.all.size.should == 1
    end

    it "accepts hound as to and bcc, creating 2 reminders" do
      @mail.to = '1h@hound.cc'
      @mail.bcc = '2h@hound.cc'
      @service.create! @mail
      Reminder.all.size.should == 2
    end
  end
  
  it "should save the Mail", type: 'integration' do
    user = Factory :user
    User.stub(:find_or_invite!).and_return user
    @service.create! @mail
    FetchedMail.first.to.should == @mail.to
  end

  it "should queue an error notification for an invalid hound address" do
      ResqueSpec.reset!
      Reminder.count.should == 0 #sanity
      @mail = Mail.new(from: 'pimpboiwonder@vuvuzela.com',
                         to: 'aslkdjf@hound.cc',
                         subject: 'test', date: DateTime.now)
      @service.create! @mail
      ErrorNotificationWorker.should have_queue_size_of(1)
    end

  describe 'replies' do
    before :each do
      @service = ReminderCreationService.new
      @root = Mail.new(from: 'sachin@siyelo.com',
                       cc: ['cc@mail.com'],
                       to: ['2days@hound.cc'],
                       message_id: '1234')

      @child = Mail.new(from: 'cc@mail.com',
                        cc: ['sachin@siyelo.com'],
                        to: ['2days@hound.cc'],
                        in_reply_to: '1234',
                        message_id: '5678')
    end

    it 'should not create a new reminder if hound recipients havent changed' do
      @service.create! @root
      @service.create! @child
      Reminder.count.should == 1
    end

    it 'should create a new reminder if hound recipients on a reply are different' do
      @service.create! @root
      @child.cc << '1h@hound.cc'
      @service.create! @child
      Reminder.count.should == 2
    end

        #root.to = ['5min@hound.cc', '10min@hound.cc']
        #@child.to = ['5min@hound.cc', '8days@hound.cc']
  end
end
