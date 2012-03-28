require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/jobs")
require 'queue_mail_job'
require 'ostruct'

class Reminder; end
class Queuer; end

describe QueueMailJob do
  it "should fetch and enqueue due&unsent reminders for active users" do
    scope = OpenStruct.new
    scope.with_active_user = nil
    Queuer.stub(:add_all_to_send_queue).and_return true
    Reminder.stub(:ready_to_send).and_return scope

    Queuer.should_receive(:add_all_to_send_queue).once
    QueueMailJob.perform
  end
end
