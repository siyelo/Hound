require 'spec_helper'

describe Users::RegistrationsController do
  let(:user) { Factory.create(:user) }

  it "should override edit and redirect to sett,ngs edit page" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    get :edit
    response.should redirect_to settings_path
  end
end
