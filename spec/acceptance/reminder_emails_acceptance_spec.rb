require 'spec_helper_acceptance'

describe "User", type: :request do
  before :each do
    ResqueSpec.reset!
    reset_mailer
  end

  it "receives a reminder email with snooze links" do
    user = Factory :user, email: 'pimp@macdaddy.yo'
    reminder = Factory :reminder, user: user,
      fetched_mail: Factory(:fetched_mail, from: 'pimp@macdaddy.yo')
    Hound::Notifier.send_reminders(reminder)
    unread_emails_for(user.email).size.should == parse_email_count(1)
    open_email(user.email)
    email_should_have_body("Snooze for:")
  end

  it "receives a reminder email with cc explanation" do
    reminder = Factory :reminder, other_recipients: 'cc@cc.yo',
      fetched_mail: Factory(:fetched_mail, from: 'pimp@macdaddy.yo')
    Hound::Notifier.send_reminders(reminder)
    unread_emails_for('cc@cc.yo').size.should == parse_email_count(1)
    open_email('cc@cc.yo')
    email_should_have_body("pimp@macdaddy.yo created this reminder for you on")
  end
end

