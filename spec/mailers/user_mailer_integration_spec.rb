require 'spec_helper'

describe UserMailer do
  describe '#reminder' do
    let (:orig_mail) { Factory :fetched_mail, body: 'body', from: 'sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] }
    let(:reminder) { Factory :reminder, fetched_mail: orig_mail, user:orig_mail.user,
     created_at: '2012-01-01' }
    let(:recipient) { 'sender@a.com' }
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

    it "says its a reminder" do
      mail.body.should match /Reminder: orig subject/
    end

    it "shows when the reminder was scheduled" do
      now =  Time.now.strftime('%d-%b')
      mail.body.should match /You created this reminder on 01-Jan/
    end

    it "shows the snooze count" do
      mail.body.should match /It has been snoozed 0 times/
    end

    it "shows the snooze links" do
      mail.body.should match /\/snooze\/(\d+)\/edit\?duration=15min&amp;token=(\w)/
    end

    it 'attaches original email body' do
      mail.body.encoded.should match(orig_mail.body)
    end
  end

  describe '#recipient_reminder' do
    let (:orig_mail) { Factory :fetched_mail, body: 'body', from: 'sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] }
    let(:reminder) { Factory :reminder, fetched_mail: orig_mail, user:orig_mail.user,
     created_at: '2012-01-01' }
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

    it "says its a reminder" do
      mail.body.should match /Reminder: orig subject/
    end

    it "shows when the reminder was scheduled" do
      now =  Time.now.strftime('%d-%b')
      mail.body.should match /sender@a.com created this reminder for you on 01-Jan/
    end

    it 'attaches original email body' do
      mail.body.encoded.should match(orig_mail.body)
    end
  end

  describe '#confirmation - welcome emails' do
    let(:user){ Factory :user, invitation_token: 'testtoken' }
    let(:in_1_hour) { Time.now.in_time_zone(user.timezone) + 1.hour }
    let (:orig_mail) { Factory :fetched_mail, body: 'body', from: 'orig_sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] , user: user }
    let(:reminder) { Factory :reminder, fetched_mail: orig_mail, user: user,
      send_at: in_1_hour}
    let(:mail) { UserMailer.confirmation(reminder, orig_mail.from) }

    it 'renders the subject' do
      mail.subject.should == 'Welcome to Hound.cc'
    end

    it 'renders the receiver email' do
      mail.to.should == ['orig_sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['reminder@hound.cc']
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
    let(:user){ Factory :user }
    let(:in_1_hour) { Time.now.in_time_zone(user.timezone) + 1.hour }
    let (:orig_mail) { Factory :fetched_mail, body: 'body', from: 'orig_sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] , user: user }
    let(:reminder) { Factory :reminder, fetched_mail: orig_mail, user: user,
      send_at: in_1_hour}
    let(:mail) { UserMailer.confirmation(reminder, orig_mail.from) }

    it 'renders the subject' do
      mail.subject.should == 'Confirmed: orig subject'
    end

    it 'renders the receiver email' do
      mail.to.should == ['orig_sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['reminder@hound.cc']
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
      mail.body.should include(confirmations_disable_url(token: user.modify_token))
    end
  end

  describe "#snooze" do
    let (:orig_mail) { Factory :fetched_mail, body: 'body', from: 'sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] }
    let(:reminder) { Factory :reminder, fetched_mail: orig_mail, user:orig_mail.user,
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

    it "says its a snooze notification " do
      mail.body.should match /Snoozed: orig subject/
    end

    it "shows the snooze count" do
      mail.body.should match /This reminder was snoozed by sender@a.com until Sun, 01 January 2012 10:00 AM EET/
    end

    it 'attaches original email body' do
      mail.body.encoded.should match(orig_mail.body)
    end
  end

  describe '#error' do
    let(:user){ Factory :user }
    let(:in_1_hour) { Time.now.in_time_zone(user.timezone) + 1.hour }
    let (:orig_mail) { Factory :fetched_mail, from: 'orig_sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] , user: user }
    let(:mail) { UserMailer.error(orig_mail) }

    it 'renders the subject' do
      mail.subject.should == 'Date problem: orig subject'
    end

    it 'renders the receiver email' do
      mail.to.should == ['orig_sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['reminder@hound.cc']
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
