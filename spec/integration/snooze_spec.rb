require 'spec_helper_acceptance'

describe "Snooze", type: :request do
  before :each do
    ResqueSpec.reset!
    reset_mailer
    @user = Factory :user, email: 'pimp@macdaddy.yo'
  end

  it "allows user to snooze and notify participants" do
    reminder = Factory :reminder, user: @user,
      other_recipients: ['d@d.com', 'g@g.com'],
      fetched_mail: Factory(:fetched_mail, from: 'pimp@macdaddy.yo')
    Hound::Notifier.send_reminders(reminder)
    open_email(@user.email)
    visit_in_email('15min')
    page.should have_content("15 minutes from now")
    page.should have_content("Would you like to notify the other recipients (d@d.com, g@g.com) that you've snoozed the reminder?")
  end

  it "does not show option to notify if there are no other participants" do
    reminder = Factory :reminder, user: @user, other_recipients: [],
      other_recipients: ['d@d.com'],
      fetched_mail: Factory(:fetched_mail, from: 'pimp@macdaddy.yo')
    Hound::Notifier.send_reminders(reminder)
    open_email(@user.email)
    visit_in_email('12h')
    page.should have_content("12 hours from now")
    page.should have_content("Would you like to notify the other recipients (d@d.com) that you've snoozed the reminder?")
  end
end


