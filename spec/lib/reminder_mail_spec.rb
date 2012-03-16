require 'reminder_mail'
require 'ostruct'

describe ReminderMail do

  class HoundAddressList < Array; end

  let(:send_at){ DateTime.now }
  let(:fetched_mail) { OpenStruct.new subject: 's', body: 'b',
    from: 'pimp@juice.com', all_addresses: ['1d@hound.cc', 'cc@example.com'] }
  let(:reminder) { mock :reminder, is_bcc?: false, send_at: send_at, fetched_mail: fetched_mail }
  let(:rm) { ReminderMail.new(reminder) }

  it "should delegate body and subject to fetched_mail" do
    rm.subject.should == 's'
    rm.body.should == 'b'
  end

  it "should return the original mail from for reminder_mail to" do
    rm.to.should == 'pimp@juice.com'
  end

  it "should delegate send_at to reminder" do
    rm.send_at.should == send_at
  end

  it "should return an array of all reminder recipients" do
    HoundAddressList.stub(:new).and_return(['1d@hound.cc'])
    rm.all_recipients.should include 'pimp@juice.com'
    rm.all_recipients.should include 'cc@example.com'
    rm.all_recipients.size.should == 2
  end

  it "should not include @hound addresses in reminders' cc field" do
    HoundAddressList.stub(:new).and_return(['1d@hound.cc'])
    fetched_mail.all_addresses = ['1d@hound.cc', 'cc@example.com'] #mock !
    r = mock :reminder, is_bcc?: false, send_at: send_at, fetched_mail: fetched_mail
    ReminderMail.new(r).cc.should == ['cc@example.com']
  end

  it "reminder cc should be empty if hound was bcc'ed" do
    HoundAddressList.stub(:new).and_return(['1d@hound.cc'])
    r = mock :reminder, is_bcc?: true, send_at: send_at, fetched_mail: fetched_mail
    ReminderMail.new(r).cc.should == []
  end

  it "should allow assignment and retrieval of errors" do
    errors = { some: 'errors' }
    r = ReminderMail.new(reminder, errors)
    r.errors.should == errors
  end
end
