require 'hound/services/reminder_mail_updater'
require 'ostruct'

describe Hound::ReminderMailUpdater do
  module ActiveRecord
    class Base
      def self.transaction(&block)
        block.call
      end
    end
  end

  let(:params) { { id: 1, reminder_mail: { send_at: "some date", delivered: 'true',
    subject: 'subject', body: 'body', cc: 'cc'} } }
  let(:fetched_mail) { OpenStruct.new save!: true, errors: {} }
  let(:reminder) { OpenStruct.new fetched_mail: fetched_mail, save!: true, errors: {}}
  let(:reminders) { mock(:scope, find_by_id: reminder) }
  let(:user) { mock :user, reminders: reminders }

  let(:updater) { Hound::ReminderMailUpdater.new }

  it "should only find reminders that belong to given user" do
    user.should_receive :reminders
    reminders.should_receive :find_by_id
    updater.perform(user, params)
  end

  it 'should instantiate with params' do
    updater.perform(user, params)
    updater.reminder.should_not be_nil
  end

  it 'should assign reminder related fields' do
    reminder.should_receive(:send_at=).with("some date")
    reminder.should_receive(:delivered=).with("true")
    reminder.should_receive(:cc=).with("cc")
    updater.perform(user, params)
  end

  it 'should assign fetched_mail related fields ' do
    fetched_mail.should_receive(:subject=).with("subject")
    fetched_mail.should_receive(:body=).with("body")
    fetched_mail.should_not_receive(:cc=)
    updater.perform(user, params)
  end

  it 'should perform an update' do
    reminder.should_receive(:save!)
    fetched_mail.should_receive(:save!)
    updater.perform(user, params)
  end

  it 'should return true if all OK' do
    updater.perform(user, params).should == true
  end

  it 'should rollback if one entity save fails' do
    reminder.stub(:save!).and_raise Exception.new
    fetched_mail.should_not_receive(:save!)
    updater.perform(user, params).should == false
  end

  it 'should catch the exception if one entity save fails' do
    reminder.stub(:save!).and_raise Exception.new
    lambda do
      updater.perform(user, params)
    end.should_not raise_exception
  end

  it "should fail if reminder id not found" do
    reminders = mock :scope, find_by_id: nil
    user = mock :user, reminders: reminders
    updater.perform(user, params).should == false
  end

  it "has empty errors if all saved ok" do
    updater.perform(user, params).should == true
    updater.errors.should be_empty
  end

  it ".errors on reminder" do
    reminder.stub(:save!).and_raise Exception.new
    errors = {some_error: 'some error'}
    reminder.stub(:errors).and_return errors
    updater.perform(user, params)
    updater.errors.should == errors
  end

  it ".errors on fetched mail" do
    fetched_mail.stub(:save!).and_raise Exception.new
    errors = {some_error: 'some error'}
    fetched_mail.stub(:errors).and_return errors
    updater.perform(user, params)
    updater.errors.should == errors
  end

  it "should combine formatted date & time params into UTC time" do
    Time.zone = "Harare"
    params = { id: 1, formatted_date: '2012-12-31', formatted_time: '02:45',
      reminder_mail: { subject: 'subject' } }
    updater.perform(user, params)
    updater.reminder.send_at.should == DateTime.parse('2012-12-31 00:45')
  end

  it 'should build a valid reminder mail' do
    updater.perform(user, params)
    rm = updater.reminder_mail
    rm.reminder.should == reminder
    rm.fetched_mail.should == fetched_mail
  end

  it 'should assign errors to the reminder mail presenter' do
    fetched_mail.stub(:save!).and_raise Exception.new
    errors = {some_error: 'some error'}
    fetched_mail.stub(:errors).and_return errors
    updater.perform(user, params)
    rm = updater.reminder_mail
    rm.errors.should == errors
  end
end
