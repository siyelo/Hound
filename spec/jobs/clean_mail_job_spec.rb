require  'spec_helper'

describe CleanMailJob do
  let (:two_weeks_and_minute) { 2.weeks + 1.minute }
  let (:minute_before_two_weeks) { 2.weeks - 1.minute }
  let (:mail) { FactoryGirl.create(:fetched_mail,
                        to: ['1m@hound.cc'],
                        from: 'user@example.com',
                        cc: ['cc@example.com'],
                        bcc: ['bcc@example.com'],
                        subject: 'my subject',
                        body: 'my body',
                        message_id: 'message_id',
                        in_reply_to: 'in_repty_to@example.com') }

  describe ".perform" do
    it "cleans delivered reminders older than 2 weeks" do
      reminder = FactoryGirl.create(:reminder,
                         fetched_mail: mail,
                         send_at: Time.now - two_weeks_and_minute,
                         delivered: true,
                         cleaned: false,
                         other_recipients: ['other_recipient@example.com'])

      CleanMailJob.perform
      reminder.reload
      fetched_mail = reminder.fetched_mail

      reminder.other_recipients.should be_empty
      reminder.cleaned.should be_true
      fetched_mail.from.should == 'user@example.com'
      fetched_mail.message_id.should == 'message_id'
      fetched_mail.to.should == ['1m@hound.cc']
      fetched_mail.cc.should be_empty
      fetched_mail.bcc.should be_empty
      fetched_mail.subject.should be_nil
      fetched_mail.body.should be_blank
      fetched_mail.in_reply_to.should be_nil
    end

    it "does not clean delivered reminders newer than 2 weeks" do
      reminder = FactoryGirl.create(:reminder,
                         fetched_mail: mail,
                         send_at: Time.now - minute_before_two_weeks,
                         delivered: true,
                         cleaned: false,
                         other_recipients: ['other_recipient@example.com'])

      CleanMailJob.perform
      reminder.reload
      fetched_mail = reminder.fetched_mail

      reminder.other_recipients.should == ['other_recipient@example.com']
      fetched_mail.from.should == 'user@example.com'
      fetched_mail.message_id.should == 'message_id'
      fetched_mail.to.should == ['1m@hound.cc']
      fetched_mail.cc.should == ['cc@example.com']
      fetched_mail.bcc.should == ['bcc@example.com']
      fetched_mail.subject.should == 'my subject'
      fetched_mail.body.should == 'my body'
      fetched_mail.in_reply_to.should == 'in_repty_to@example.com'
    end

    it "does not clean undelivered reminders" do
      reminder = FactoryGirl.create(:reminder,
                         fetched_mail: mail,
                         send_at: Time.now - two_weeks_and_minute,
                         delivered: false,
                         cleaned: false,
                         other_recipients: ['other_recipient@example.com'])

      CleanMailJob.perform
      reminder.reload
      fetched_mail = reminder.fetched_mail

      reminder.other_recipients.should == ['other_recipient@example.com']
      fetched_mail.from.should == 'user@example.com'
      fetched_mail.message_id.should == 'message_id'
      fetched_mail.to.should == ['1m@hound.cc']
      fetched_mail.cc.should == ['cc@example.com']
      fetched_mail.bcc.should == ['bcc@example.com']
      fetched_mail.subject.should == 'my subject'
      fetched_mail.body.should == 'my body'
      fetched_mail.in_reply_to.should == 'in_repty_to@example.com'
    end

    it "does not clean already cleaned reminders" do
      reminder = FactoryGirl.create(:reminder,
                         fetched_mail: mail,
                         send_at: Time.now - two_weeks_and_minute,
                         delivered: true,
                         cleaned: true,
                         other_recipients: ['other_recipient@example.com'])

      CleanMailJob.perform
      reminder.reload
      fetched_mail = reminder.fetched_mail

      reminder.other_recipients.should == ['other_recipient@example.com']
      fetched_mail.from.should == 'user@example.com'
      fetched_mail.message_id.should == 'message_id'
      fetched_mail.to.should == ['1m@hound.cc']
      fetched_mail.cc.should == ['cc@example.com']
      fetched_mail.bcc.should == ['bcc@example.com']
      fetched_mail.subject.should == 'my subject'
      fetched_mail.body.should == 'my body'
      fetched_mail.in_reply_to.should == 'in_repty_to@example.com'
    end
  end
end
