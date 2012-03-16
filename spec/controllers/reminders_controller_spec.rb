require  'spec_helper_lite'
$: << File.join(APP_ROOT, "app/controllers")

# A test double for ActionController::Base
module ActionController
  class Base
    def self.protect_from_forgery; end
  end
end

class ApplicationController
  def self.before_filter(*args); end
end

require 'reminders_controller'

class ReminderMail; end
class ReminderFilter; end

describe RemindersController do
  let(:controller) { RemindersController.new }
  let(:user) { mock :user, reminders: [] }
  before :each do
    controller.stub(:current_user).and_return user
  end

  it "should render index" do
    controller.class.send(:define_method, :params) do
      {}
    end
    reminder_filter = stub
    ReminderFilter.stub(:new).and_return reminder_filter
    controller.index.should == reminder_filter
  end
end

