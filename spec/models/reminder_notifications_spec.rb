require 'spec_helper'

#TODO refactor into observers /separate service
describe Reminder do
  before :each do
    ResqueSpec.reset!
  end


  it "should not include the snooze links for cc'ed users" do
    reminder = Factory :reminder, subject: "mehpants", cc: "wat@wiggle.com"
    @email = UserMailer.send_reminder(reminder, reminder.cc.first)
    @email.should_not have_body_text('/Snooze for:/')
  end


  it "should append 'RE: ' before the emails subject" do
    reminder = Factory :reminder, subject: "mehpants"
    @email = UserMailer.send_reminder(reminder, reminder.email)
    @email.should have_subject(/Re: mehpants/)
  end
end
