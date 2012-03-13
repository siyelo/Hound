require 'spec_helper'

describe ReminderMail do
  it "should not include @hound addresses in reminders' cc field" do
    pending
    mail = Factory :fetched_mail, from: 'sachin@siyelo.com',
                       to: ['2days@hound.cc'],
                       cc: ['1min@hound.cc', 'cc@example.com'],
                       subject: 'test', date: DateTime.now
    rm = ReminderMail.new(mail, false)
    rm.cc.should == ['cc@example.com']
  end

  it "reminder cc should be empty if hound was bcc'ed" do
    pending
    emails = [Mail.new(from: 'sachin@siyelo.com',
                       to: ['anyone@anyone.com'],
                       cc: ['wat@huh.com'],
                       bcc: ['1min@hound.cc'],
                       subject: 'test', date: DateTime.now)]

  end

  it "reminder cc should be empty if hound was bcc'ed" do
    pending
    emails = [Mail.new(from: 'sachin@siyelo.com',
                       to: ['1hour@hound.cc'],
                       cc: ['wat@huh.com'],
                       bcc: ['1min@hound.cc'],
                       subject: 'test', date: DateTime.now)]

  end
end
