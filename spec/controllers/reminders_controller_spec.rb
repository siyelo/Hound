require 'spec_helper'

describe RemindersController do
  include Devise::TestHelpers

  it "should redirect to sign-in page if user not authenticated" do
    get 'index'
    response.should redirect_to(new_user_session_path)
  end

  context "authenticated" do
    before :each do
      user = Factory.create(:user)
      sign_in user
    end

    it "should render the index" do
      get 'index'
      assigns(:presenter).should_not be_nil
      response.should be_success
    end

    it 'should redirect to index when trying to edit a reminder that doesnt exist' do
      get 'edit'
      response.should redirect_to(reminders_path)
    end
  end
end
