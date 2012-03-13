require 'spec_helper'

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
