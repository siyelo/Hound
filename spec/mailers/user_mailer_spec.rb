require 'spec_helper'

describe UserMailer do
  let (:orig_mail) { FactoryGirl.create :fetched_mail, body: 'body', from: 'sender@a.com',
    :subject => 'orig subject', cc: ['cc@a.com'], to: ['1d@hound.cc'], message_id: '42' }
  let(:in_1_hour) { Time.now.in_time_zone(orig_mail.user.timezone) + 1.hour }
  let(:reminder) { FactoryGirl.create :reminder, fetched_mail: orig_mail, user: orig_mail.user,
   created_at: '2012-01-01', send_at: in_1_hour}
  let(:recipient) { 'sender@a.com' }

  describe 'shared reminder' do
    let(:mail) { UserMailer.reminder(reminder, recipient) }

    it 'renders the subject' do
      mail.subject.should == 'Re: orig subject'
    end

    it 'sends it to the original sender' do
      mail.to.should == ['sender@a.com']
    end

    it 'sends it from hound' do
      mail.from.should == ['reminder@hound.cc']
    end

    it 'threads it with original mail' do
      mail.in_reply_to.should == '<42>'
    end

    it "says its a reminder" do
      mail.body.should have_content('orig subject')
    end

    it "shows when the reminder was scheduled" do
      now =  Time.now.strftime('%d-%b')
      mail.body.should match /You created this.<b>shared<\/b>.reminder on.<b>01-Jan<\/b>/m
    end

    it "shows the snooze count" do
      mail.body.should have_content('It has been snoozed 0 times')
    end

    it "shows the snooze links" do
      mail.body.should match /\/snooze\/(\d+)\/edit\?duration=15min&amp;token=(\w)/
    end

    it 'attaches original email body' do
      mail.body.encoded.should match(orig_mail.body)
    end

    it 'contains the original to addresses without hound' do
      mail.body.should_not match /mailto:1d@hound.cc/
    end

    it 'contains the original cc addresses without hound' do
      mail.body.should match /mailto:cc@a.com/
    end

    it 'contains a reply all link for shared reminders' do
      mail.body.should match /mailto:\?cc=cc%40a\.com&amp;subject=Re%3A%20orig%20subject/
    end
  end

  describe 'private reminder' do
    let (:private_mail) { FactoryGirl.create :fetched_mail, body: 'body', from: 'sender@a.com',
      subject: 'orig subject', cc: [], bcc: ['1d@hound.cc'], message_id: '43' }
    let(:private_reminder) { FactoryGirl.create :reminder, user: private_mail.user,
      created_at: '2012-01-01', send_at: in_1_hour, other_recipients: []}
    let(:mail) { UserMailer.reminder(private_reminder, recipient) }

    it "shows that the reminder is private" do
      mail.body.should match /You created this.<b>private<\/b>.reminder/m
    end

    it 'contains the original to addresses without hound' do
      mail.body.should_not match /mailto:1d@hound.cc/
    end
  end

  describe '#recipient_reminder' do
    let(:recipient) { 'cc@a.com' }
    let(:mail) { UserMailer.recipient_reminder(reminder, recipient) }

    it 'renders the subject' do
      mail.subject.should == 'Re: orig subject'
    end

    it 'renders the receiver email' do
      mail.to.should == ['cc@a.com']
    end

    it 'sends it from hound' do
      mail.from.should == ['reminder@hound.cc']
    end

    it 'sets reply-to as original sender' do
      mail.reply_to.should == ['sender@a.com']
    end

    it 'threads it with original mail' do
      mail.in_reply_to.should == '<42>'
    end

    it "says its a reminder" do
      mail.body.should match /Reminder:/
    end

    it "shows when the reminder was scheduled" do
      now =  Time.now.strftime('%d-%b')
      mail.body.should have_content('sender@a.com created this reminder on 01-Jan')
    end

    it 'attaches original email body' do
      mail.body.encoded.should match(orig_mail.body)
    end
  end

  describe '#confirmation - welcome emails' do
    let(:user){ FactoryGirl.create :user, invitation_token: 'testtoken' }
    let(:in_1_hour) { Time.now.in_time_zone(user.timezone) + 1.hour }
    let (:orig_mail) { FactoryGirl.create :fetched_mail, from: 'sender@a.com',
      :subject => 'orig subject', user: user, message_id: '42'}
    let(:reminder) { FactoryGirl.create :reminder, fetched_mail: orig_mail, user: user,
      send_at: in_1_hour}
    let(:mail) { UserMailer.confirmation(reminder, orig_mail.from) }

    it 'renders the subject' do
      mail.subject.should == 'Welcome to Hound.cc'
    end

    it 'renders the receiver email' do
      mail.to.should == ['sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['reminder@hound.cc']
    end

    it 'threads it with original mail' do
      mail.in_reply_to.should == '<42>'
    end

    it 'assigns send_at' do
      mail.body.should match(in_1_hour.to_formatted_s(:rfc822_with_zone))
    end

    it 'assigns edit_reminder_url' do
      mail.body.should match("/reminders/#{reminder.id}/edit")
    end

    it 'assigns edit_notification_url' do
      mail.body.should match(/\/activate\?invitation_token=testtoken/)
    end
  end

  describe '#confirmation - confirmations' do
    let(:mail) { UserMailer.confirmation(reminder, orig_mail.from) }

    it 'renders the subject' do
      mail.subject.should == 'Confirmed: orig subject'
    end

    it 'renders the receiver email' do
      mail.to.should == ['sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['reminder@hound.cc']
    end

    it 'threads it with original mail' do
      mail.in_reply_to.should == '<42>'
    end

    it 'assigns send_at' do
      mail.body.should match(in_1_hour.to_formatted_s(:rfc822_with_zone))
    end

    it 'allows user to go directly to upcoming reminders' do
      mail.body.should match /\/reminders(.*)Upcoming(.*)$/
    end

    it 'allows user to go directly to settings' do
      mail.body.should match /\/settings(.*)Settings(.*)$/
    end

    it 'assigns edit_reminder_url' do
      mail.body.should match("/reminders/#{reminder.id}/edit")
    end

    it 'allows user to turn confirmations off' do
      mail.body.should match /Don\'t need a confirmation every time you schedule a reminder\?/
      mail.body.should include(confirmations_disable_url(token: orig_mail.user.modify_token))
    end
  end

  describe "#snooze" do
    let(:reminder) { FactoryGirl.create :reminder, fetched_mail: orig_mail, user:orig_mail.user,
     created_at: '2012-01-01', send_at: DateTime.parse("2012-01-01 08:00:00"), snooze_count: 1}
    let(:mail) { UserMailer.snooze(reminder, 'cc@a.com') }

    it 'renders the subject' do
      mail.subject.should == 'Re: orig subject'
    end

    it 'sends it to the given recipient' do
      mail.to.should == ['cc@a.com']
    end

    it 'sends it from hound' do
      mail.from.should == ['reminder@hound.cc']
    end

    it 'sets reply-to as the original sender' do
      mail.reply_to.should == ['sender@a.com']
    end

    it 'threads it with original mail' do
      mail.in_reply_to.should == '<42>'
    end

    it "says its a snooze notification " do
      mail.body.should match /Snoozed: orig subject/
    end

    it "shows the snooze count" do
      mail.body.should have_content('This reminder was snoozed by sender@a.com until Sun, 01 January 2012 10:00 AM EET')
    end

    it 'attaches original email body' do
      mail.body.encoded.should match(orig_mail.body)
    end
  end

  describe '#error' do
    let(:mail) { UserMailer.error(orig_mail) }

    it 'renders the subject' do
      mail.subject.should == 'Date problem: orig subject'
    end

    it 'renders the receiver email' do
      mail.to.should == ['sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['reminder@hound.cc']
    end

    it 'threads it with original mail' do
      mail.in_reply_to.should == '<42>'
    end

    it 'apologizes for their stupidity' do
      mail.body.should match /Sorry, we couldn\'t recognize all of the \"\.\.\.@hound.cc\" date formats/
    end

    it 'allows user to contact us for more help' do
      mail.body.should match /hound.uservoice.com/
    end

    it 'shows available date formats' do
      mail.body.should match /Composite/
    end
  end
end
