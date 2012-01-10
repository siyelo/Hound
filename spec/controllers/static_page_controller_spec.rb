require 'spec_helper'

describe StaticPageController do
  login_user

  it "should have a current_user" do
    subject.current_user.should_not be_nil
  end

  it "should get index" do
    get 'index'
    response.should be_success
  end
end

