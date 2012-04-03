require 'spec_helper_acceptance'

describe "Snooze", type: :request do
  before :each do
    ResqueSpec.reset!
    reset_mailer
    @user = Factory :user, email: 'pimp@macdaddy.yo'
  end

  it "allows user to snooze and notify participants" do
    reminder = Factory :reminder, user: @user, fetched_mail: Factory(:fetched_mail, from: 'pimp@macdaddy.yo')
    Notifier.send_reminder_email(reminder)
    open_email(@user.email)
    visit_in_email('15m')
    page.should have_content("15 minutes from now")
    page.should have_content("Would you like to notify the other recipients")
  end

  it "does not show option to notify if there are no other participants" do
    reminder = Factory :reminder, user: @user, other_recipients: [],
      fetched_mail: Factory(:fetched_mail, from: 'pimp@macdaddy.yo')
    Notifier.send_reminder_email(reminder)
    open_email(@user.email)
    visit_in_email('12h')
    page.should have_content("12 hours from now")
    page.should_not have_content("Would you like to notify the other recipients")
  end
end


