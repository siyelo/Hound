require  'spec_helper'

describe FetchMailJob do
  let(:imap) { mock('imap') }

  before :each do
    Net::IMAP.should_receive(:new).with(FetchMailJob::SERVER, :ssl => true).and_return(imap)
    imap.should_receive(:login).with(FetchMailJob::USERNAME, FetchMailJob::PASSWORD)
    imap.should_receive(:select).with(FetchMailJob::FOLDER)
    @job = FetchMailJob.clone # because it's singleton
  end

  describe "#start" do
    it "can fetch messages on start" do
      @job.instance.should_receive(:fetch_messages).once
      @job.instance.should_not_receive(:wait_for_messages)
      @job.instance.should_receive(:loop).and_return('no loop')
      @job.instance.start
    end

    it "can wait and fetch messages in a loop" do
      @job.instance.should_receive(:fetch_messages).twice
      @job.instance.should_receive(:wait_for_messages)
      @job.instance.should_receive(:loop).and_yield
      @job.instance.start
    end
  end

  describe "#stop" do
    it "can stop disconnect and stop the process" do
      imap.should_receive(:disconnect)
      @job.instance.should_receive(:exit)
      @job.instance.stop
    end
  end

  describe "#save_mail" do
    it "creates a reminder from a received mail" do
      mail = Mail.new(from: "from@example.com", to: "1d@hound.cc",
               body: "abcdefg", subject: "asubject", cc: "cc@example.com",
               bcc: "bcc@example.com", in_reply_to: "in_reply_to@example.com")
      service = mock
      ReminderCreationService.stub(:new).and_return(service)
      service.should_receive(:create!).once.with(mail)
      @job.instance.save_mail(mail)
    end
  end

  describe "#fetch_messages" do
    it "can fetch messages" do
      mail      = mock('Mail object', message_id: 'message id')
      rfc_data  = mock('RFC822')
      fetched_data = mock('fetched_data', attr: {'RFC822' => rfc_data})
      imap.should_receive(:uid_search).with(["ALL"]).and_return(['1'])
      imap.should_receive(:uid_fetch).with('1', ['RFC822']).and_return([fetched_data])
      Mail.should_receive(:new).with(rfc_data).and_return(mail)
      @job.instance.should_receive(:save_mail).with(mail)
      imap.should_receive(:uid_store).with('1', "+FLAGS", [:Deleted])

      @job.instance.fetch_messages
    end
  end

  describe "#wait_for_messages" do
    it "keeps an active connection" do
      resp = mock("resp", name: "EXISTS", data: '1')
      resp.should_receive(:"kind_of?").with(Net::IMAP::UntaggedResponse).and_return(true)
      imap.should_receive(:idle).and_yield(resp)
      imap.should_receive(:idle_done)

      @job.instance.wait_for_messages
    end

    it "can rescue from Net::IMAP::Error exception" do
      imap.stub(:idle).and_raise(Net::IMAP::Error)

      @job.instance.wait_for_messages.should be_nil
    end
  end
end
