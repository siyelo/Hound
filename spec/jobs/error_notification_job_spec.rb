require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/jobs")
require 'error_notification_job'
require 'ostruct'

module Hound
  class Notifier; end
end

describe ErrorNotificationJob do
  it "should use the error queue" do
    ErrorNotificationJob.instance_variable_get(:@queue).should == :error_queue
  end

  it "should call the Notifier service" do
    Hound::Notifier.should_receive(:send_error_notification).with(1)
    ErrorNotificationJob.perform(1)
  end
end

