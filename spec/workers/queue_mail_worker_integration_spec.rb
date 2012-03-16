require  'spec_helper'

describe QueueMailWorker do
  before :each do
    @now = Time.now
    due = Factory :reminder, send_at: @now
  end

  it "should fetch and enqueue due&unsent reminders for active users" do
    Queuer.should_receive(:add_all_to_send_queue).once
    QueueMailWorker.perform
  end
end
