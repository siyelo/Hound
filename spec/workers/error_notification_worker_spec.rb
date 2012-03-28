require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/workers")
require 'error_notification_worker'
require 'ostruct'

class FetchedMail; end
class UserMailer; end

describe ErrorNotificationWorker do
  it "should use the error queue" do
    ErrorNotificationWorker.instance_variable_get(:@queue).should == :error_queue
  end

  it "should fetch the FetchedMail by id" do
    mail = OpenStruct.new
    mail.deliver = nil
    FetchedMail.stub(:find_by_id).and_return nil
    UserMailer.stub(:send_error_notification).and_return mail
    FetchedMail.should_receive(:find_by_id).with(1).once
    ErrorNotificationWorker.perform(1)
  end
end

