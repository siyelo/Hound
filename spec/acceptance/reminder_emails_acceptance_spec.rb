require 'spec_helper_acceptance'

feature "reminder emails" do
  background do
    ResqueSpec.reset!
    reset_mailer
  end

  scenario "should receive a reminder email with snooze links" do
    user = Factory :user, email: 'pimp@macdaddy.yo'
    reminder = Factory :reminder, user: user, fetched_mail: Factory(:fetched_mail, from: 'pimp@macdaddy.yo')
    Notifier.send_reminder_email(reminder)
    unread_emails_for(user.email).size.should == parse_email_count(1)
    open_email(user.email)
    email_should_have_body("Snooze for:")
  end

  scenario "should receive a reminder email with cc explanation" do
    reminder = Factory :reminder, fetched_mail: Factory(:fetched_mail, cc: 'cc@cc.yo')
    Notifier.send_reminder_email(reminder)
    unread_emails_for('cc@cc.yo').size.should == parse_email_count(1)
    open_email('cc@cc.yo')
    email_should_have_body("You are receiving this email because you were listed as a recipient on the original email")
  end
end

