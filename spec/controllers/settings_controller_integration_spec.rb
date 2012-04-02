require 'spec_helper'

describe SettingsController do
  context "signed in user" do
    let(:user) { Factory.create(:user) }

    before :each do
      sign_in user
    end

    it "shows edit settings" do
      get 'edit'
      response.should be_success
    end

    it "updates without password" do
      put :update, id: user.id, user: {'email' => 'g1@g.com'}
      flash[:notice].should == "You have successfully updated your settings."
      response.should redirect_to settings_path
    end

    it "updates, ignoring password" do
      put :update, id: user.id, user: {'password' => 'abcdef'}
      flash[:notice].should == "You have successfully updated your settings."
      response.should redirect_to settings_path
    end

    it "updates password" do
      put :update_password, id: user.id, user: { 'current_password' => 'testing',
        'password' => 'abcdef' }
      flash[:notice].should == "You have successfully updated your password."
      response.should redirect_to settings_path
    end
  end

  context "unauthenticated user" do
    it "redirects to sign in page when user not signed in" do
      get 'edit'
      response.should redirect_to(new_user_session_path)
    end
  end
end
