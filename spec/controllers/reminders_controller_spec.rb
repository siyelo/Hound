require 'spec_helper'

describe RemindersController do
  include Devise::TestHelpers

  it "should redirect to sign-in page if user not authenticated" do
    get 'index'
    response.should redirect_to(new_user_session_path)
  end

  it 'should redirect to index when trying to edit reminder that doesnt exist' do
    user = Factory.create(:user)
    sign_in user
    get 'edit'
    response.should redirect_to(reminders_path)
  end

end
