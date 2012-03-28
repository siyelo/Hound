require 'spec_helper'

describe ReminderConfirmationObserver do
  before :each do
    ResqueSpec.reset!
  end

  it "should send a confirmation email" do
    reminder = Factory :reminder
    SendConfirmationJob.should have_queue_size_of(1)
  end

  it "should not send a confirmation email if user doesnt want" do
    reminder = Factory :reminder, user: Factory(:user, confirmation_email: false)
    SendConfirmationJob.should have_queue_size_of(0)
  end
end
