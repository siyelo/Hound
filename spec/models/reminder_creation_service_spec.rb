require 'spec_helper'

describe ReminderCreationService do
  before :each do
    @date = stub :Date, zone: Time.zone.now.zone
    @mail = stub :Mail, from: 'a@a.com', date: @date, to: '1h@hound.cc'
    @mail_klass = stub "Class::Mail", create: @mail
    @reminder = stub :Reminder
    @reminder_klass = stub "Class::Reminder", create: @reminder
    @user = stub :User
    @user_klass = stub "Class::User", find_by_email_or_alias: @user, invite!: @user
    @one_hour_from_now = Time.now + 1.hour
    @parser_klass= stub "Class::EmailParser::Dispatcher", parse_email: @one_hour_from_now
    @service = ReminderCreationService.new(@mail_klass, @reminder_klass, @user_klass, @parser_klass)
    @params = {}
  end

  it "creates the mail with the supplied parameters" do
    pending
    @mail_klass.should_receive(:create).with(@params)
    @service.create @params
  end

  it "checks if the sender has an existing account" do
    @user_klass.should_receive(:find_by_email_or_alias).with(@mail.from)
    @service.create @params
  end

  it "invites the sender to join if no account found" do
    utc_name = 'Casablanca'
    @user_klass.stub(:find_by_email_or_alias).and_return(nil.as_null_object)
    @user_klass.should_receive(:invite!).with(email: @mail.from, timezone: utc_name)
    @service.create @params
  end

  it "creates the reminder with the supplied parameters" do
    pending
    @reminder_klass.should_receive(:create)
    #.with(@user, @send_at, @mail)
    @service.create @params
  end

  it "should parse each hound.cc address for a correct date" do
    @parser_klass.should_receive(:parse_email).with(@mail.to).and_return(@one_hour_from_now)
    @service.create @params
  end

  it "should match an existing message thread" do
    pending
  end

  it "should create one reminder per hound.cc address in the mail" do
    pending
  end

  it "should find or invite a user" do
    pending
  end

  it "should deliver an error notification if the hound address is invalid" do
    pending
  end

  it "should not create a mail/user/reminder if the hound address is incorrect" do
    pending
  end

end
