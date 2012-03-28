require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/jobs")
require 'error_notification_job'
require 'ostruct'

class FetchedMail; end
class UserMailer; end

describe ErrorNotificationJob do
  it "should use the error queue" do
    ErrorNotificationJob.instance_variable_get(:@queue).should == :error_queue
  end

  it "should fetch the FetchedMail by id" do
    mail = OpenStruct.new
    mail.deliver = nil
    FetchedMail.stub(:find_by_id).and_return nil
    UserMailer.stub(:send_error_notification).and_return mail
    FetchedMail.should_receive(:find_by_id).with(1).once
    ErrorNotificationJob.perform(1)
  end
end

