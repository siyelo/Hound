require 'spec_helper'

describe "User", type: :request do

  def send_email_and_confirmation
    # send mail to hound.cc
    mail = Mail.new(from: 'user@hound.cc', to: '1d@hound.cc', subject: 'bug', body: 'bug')
    service = ReminderCreationService.new
    service.create!(mail)

    # send reminder
    reminder = Reminder.last
    UserMailer.confirmation(reminder).deliver!
    reminder
  end

  it "can accept invitation by reseting password" do
    reminder = send_email_and_confirmation
    user     = reminder.user

    unread_emails_for(user.email).size.should == parse_email_count(1)
    open_email(user.email)
    current_email.should have_subject('Welcome to Hound.cc')
    current_email.should have_body_text("Yes it's me! Activate my account!")

    reset_mailer

    visit root_path
    click_link "Login"
    click_link "Forgot your password?"
    fill_in "Email", with: "user@hound.cc"
    click_button "Reset Password"
    unread_emails_for(user.email).size.should == parse_email_count(1)
    open_email(user.email)
    current_email.should have_subject('Reset password instructions')
    visit_in_email('Change my password')
    fill_in "Choose a new password", with: "password"
    click_button "Change my password"

    reset_mailer

    reminder = send_email_and_confirmation
    user     = reminder.user
    unread_emails_for(user.email).size.should == parse_email_count(1)
    open_email(user.email)
    current_email.should have_subject('Confirmed: bug')
    current_email.should_not have_body_text("Yes it's me! Activate my account!")
  end
end
