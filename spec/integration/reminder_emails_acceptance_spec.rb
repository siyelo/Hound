require 'spec_helper_acceptance'

describe "User", type: :request do
  before :each do
    ResqueSpec.reset!
    reset_mailer
  end

  it "receives a reminder email with snooze links" do
    user = FactoryGirl.create :user, email: 'pimp@macdaddy.yo'
    reminder = FactoryGirl.create :reminder, user: user,
      fetched_mail: FactoryGirl.create(:fetched_mail, from: 'pimp@macdaddy.yo')
    Hound::Notifier.send_reminders(reminder)
    unread_emails_for(user.email).size.should == parse_email_count(1)
    open_email(user.email)
    current_email.should have_body_text("Snooze for:")
  end

  it "receives a reminder email with cc explanation" do
    reminder = FactoryGirl.create :reminder, other_recipients: 'cc@cc.yo',
      fetched_mail: FactoryGirl.create(:fetched_mail, from: 'pimp@macdaddy.yo')
    Hound::Notifier.send_reminders(reminder)
    unread_emails_for('cc@cc.yo').size.should == parse_email_count(1)
    open_email('cc@cc.yo')
    current_email.should have_body_text("<b>pimp@macdaddy.yo</b> created this reminder on")
  end
end

