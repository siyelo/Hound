require 'spec_helper'

describe UserMailer do
  describe '#send_reminder' do
    let (:orig_mail) { Factory :fetched_mail, body: 'body', from: 'sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] }
    let(:reminder) { Factory :reminder, fetched_mail: orig_mail, user:orig_mail.user }
    let(:recipient) { 'from_or_ccd@a.com' }
    let(:mail) { UserMailer.send_reminder(reminder, recipient) }

    #ensure that the subject is correct
    it 'renders the subject' do
      mail.subject.should == 'Re: orig subject'
    end

    #ensure that the receivers include
    it 'renders the receiver email' do
      mail.to.should == ['from_or_ccd@a.com']
    end

    #ensure that the sender is correct
    it 'renders the sender email' do
      mail.from.should == ['noreply@hound.cc']
    end

    #ensure that the @name variable appears in the email body
    it 'assigns @name' do
      mail.body.encoded.should match(orig_mail.body)
    end
  end

  describe '#send_confirmation - welcome emails' do
    let(:user){ Factory :user, invitation_token: 'testtoken' }
    let(:in_1_hour) { Time.now.in_time_zone(user.timezone) + 1.hour }
    let (:orig_mail) { Factory :fetched_mail, body: 'body', from: 'orig_sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] , user: user }
    let(:reminder) { Factory :reminder, fetched_mail: orig_mail, user: user,
      send_at: in_1_hour}
    let(:mail) { UserMailer.send_confirmation(reminder, orig_mail.from) }

    it 'renders the subject' do
      mail.subject.should == 'Welcome to Hound.cc'
    end

    it 'renders the receiver email' do
      mail.to.should == ['orig_sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['noreply@hound.cc']
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

  describe '#send_confirmation - confirmations' do
    let(:user){ Factory :user }
    let(:in_1_hour) { Time.now.in_time_zone(user.timezone) + 1.hour }
    let (:orig_mail) { Factory :fetched_mail, body: 'body', from: 'orig_sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] , user: user }
    let(:reminder) { Factory :reminder, fetched_mail: orig_mail, user: user,
      send_at: in_1_hour}
    let(:mail) { UserMailer.send_confirmation(reminder, orig_mail.from) }

    it 'renders the subject' do
      mail.subject.should == 'Confirmed: orig subject'
    end

    it 'renders the receiver email' do
      mail.to.should == ['orig_sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['noreply@hound.cc']
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
      mail.body.should match("/notifications/#{user.id}/edit") #{user.modify_token}")
    end
  end

  describe '#error_notification' do
    let(:user){ Factory :user }
    let(:in_1_hour) { Time.now.in_time_zone(user.timezone) + 1.hour }
    let (:orig_mail) { Factory :fetched_mail, from: 'orig_sender@a.com',
      :subject => 'orig subject', cc: ['cc@a.com'] , user: user }
    let(:mail) { UserMailer.send_error_notification(orig_mail) }

    it 'renders the subject' do
      mail.subject.should == 'Date problem: orig subject'
    end

    it 'renders the receiver email' do
      mail.to.should == ['orig_sender@a.com']
    end

    it 'renders the sender email' do
      mail.from.should == ['noreply@hound.cc']
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
