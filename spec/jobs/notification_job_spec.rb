require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/jobs")
require 'notification_job'
require 'ostruct'

module Hound
  class Notifier; end
end

describe NotificationJob do
  it "should use the notification queue" do
    NotificationJob.instance_variable_get(:@queue).should == :notification_queue
  end

  it "should call the Notifier service" do
    Hound::Notifier.should_receive(:send_snooze_notifications).with(1)
    NotificationJob.perform(1)
  end
end

