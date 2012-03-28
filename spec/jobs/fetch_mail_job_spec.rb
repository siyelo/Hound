require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/jobs")
require 'fetch_mail_job'

class ReminderCreationService; end

describe FetchMailJob do
  it "should use the fetch queue" do
    FetchMailJob.instance_variable_get(:@queue).should == :fetch_queue
  end

  it "should delegate to the reminder service" do
    service = mock fetch_all_mails: true
    ReminderCreationService.stub(:new).and_return service
    service.should_receive(:fetch_all_mails)
    FetchMailJob.perform
  end
end
