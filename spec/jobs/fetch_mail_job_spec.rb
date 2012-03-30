require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/jobs")
require 'fetch_mail_job'

describe FetchMailJob do
  let(:imap) { mock('imap') }

  before :each do
    Net::IMAP.should_receive(:new).with(FetchMailJob::SERVER, :ssl => true).and_return(imap)
    imap.should_receive(:login).with(FetchMailJob::USERNAME, FetchMailJob::PASSWORD)
    imap.should_receive(:select).with(FetchMailJob::FOLDER)
  end
  describe "#save_mail" do
    it "creates a reminder from a received mail" do
      mail = Mail.new(from: "from@example.com", to: "1d@hound.cc",
               body: "abcdefg", subject: "asubject", cc: "cc@example.com",
               bcc: "bcc@example.com", in_reply_to: "in_reply_to@example.com")
      fmj = FetchMailJob.new
      service = mock
      ReminderCreationService.stub(:new).and_return(service)
      service.should_receive(:create!).once.with(mail)
      fmj.save_mail(mail)
    end
  end

  describe "#fetch_messages" do
    it "can fetch messages" do
      mail      = mock('Mail object')
      rfc_data  = mock('RFC822')
      fetched_data = mock('fetched_data', attr: {'RFC822' => rfc_data})
      fmj = FetchMailJob.new
      imap.should_receive(:search).with(["ALL"]).and_return(['1'])
      imap.should_receive(:fetch).with('1', ['RFC822']).and_return([fetched_data])
      Mail.should_receive(:new).with(rfc_data).and_return(mail)
      fmj.should_receive(:save_mail).with(mail)
      imap.should_receive(:store).with('1', "+FLAGS", [:Deleted])

      fmj.fetch_messages
    end
  end

  describe "#wait_for_messages" do
    it "keep an active connection" do
      resp = mock("resp", name: "EXISTS", data: '1')
      resp.should_receive(:"kind_of?").with(Net::IMAP::UntaggedResponse).and_return(true)
      imap.should_receive(:idle).and_yield(resp)
      imap.should_receive(:idle_done)
      service = FetchMailJob.new

      service.should_receive(:fetch_messages)

      service.wait_for_messages
    end
  end
end
