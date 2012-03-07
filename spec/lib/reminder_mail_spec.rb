require 'spec_helper'

describe ReminderMail do

  context "associated objects" do
    before :each do
      fetched_mail = Factory :fetched_mail,
        cc:['1d@hound.cc', 'cc@example.com']
      @reminder = Factory :reminder, fetched_mail: fetched_mail
      @rm = ReminderMail.new(@reminder)
    end

    it "should delegate body and subject to fetched_mail" do
      @rm.subject.should == @reminder.fetched_mail.subject
      @rm.body.should == @reminder.fetched_mail.body
    end

    it "should return the original mail from for reminder_mail to" do
      @reminder.fetched_mail.stub(:from).and_return('pimp@juice.com')
      @rm.to.should == 'pimp@juice.com'
    end

    it "should delegate send_at to reminder" do
      @rm.send_at.should == @reminder.send_at
    end

    it "should return an array of all reminder recipients" do
      @reminder.fetched_mail.stub(:from).and_return('pimp@juice.com')
      @rm.all_recipients.should include 'pimp@juice.com'
      @rm.all_recipients.should include 'cc@example.com'
      @rm.all_recipients.size.should == 2
    end
  end

  context "reminder mail cc's" do
    it "should not include @hound addresses in reminders' cc field" do
      fetched_mail = Factory :fetched_mail,
        cc:['1d@hound.cc', 'cc@example.com']
      reminder = Factory :reminder, fetched_mail: fetched_mail
      rm = ReminderMail.new(reminder)
      rm.cc.should == ['cc@example.com']
    end

    it "reminder cc should be empty if hound was bcc'ed" do
      fetched_mail = Factory :fetched_mail, bcc:['1d@hound.cc']
      reminder = Factory :reminder, fetched_mail: fetched_mail, is_bcc: true
      rm = ReminderMail.new(reminder)
      rm.cc.should == []
    end
  end

  context "updating" do
    before :each do
      @fetched_mail = Factory :fetched_mail, bcc:['1d@hound.cc']
      @reminder = Factory :reminder, fetched_mail: @fetched_mail, is_bcc: true
      @rm = ReminderMail.new(@reminder)
    end

    it "should allow updating of the reminder's send_at time" do
      new_date_time = DateTime.parse '14 December 2012'
      @rm.update_attributes({ send_at: new_date_time }).should be_true
      Reminder.find_by_id(@reminder.id).send_at.should == new_date_time
    end

    it "should allow updating of the fetched_mail's subject & body" do
      @rm.update_attributes({ subject: 'new subject', body: 'new body' }).should be_true
      FetchedMail.find_by_id(@fetched_mail.id).subject.should == 'new subject'
    end

    it "should update reminder and fetched_mail in a transaction" do
      @rm.update_attributes({ send_at: 'fefefe', subject: 'new subject' }).should be_false
      FetchedMail.find_by_id(@fetched_mail.id).subject.should_not == 'new subject'
    end

    it "should return errors for both reminders and fetched_mails" do
      @rm.update_attributes({ send_at: 'fefefe', subject: 'new subject' }).should be_false
      @rm.errors.count.should == 1
    end

    it "should allow updating of the reminders delivered" do
      @rm.update_attributes({ delivered: 'true'}).should be_true
      Reminder.find_by_id(@reminder.id).delivered?.should == true
    end
  end
end
