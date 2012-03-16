require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/workers")
require 'fetch_mail_worker'

class ReminderCreationService
  def fetch_all_mails; end
end

describe FetchMailWorker do
  it "should use the fetch queue" do
    FetchMailWorker.instance_variable_get(:@queue).should == :fetch_queue
  end

  it "should delegate to the reminder service" do
    service = mock fetch_all_mails: true
    ReminderCreationService.stub(:new).and_return service
    service.should_receive(:fetch_all_mails)
    FetchMailWorker.perform
  end
end
