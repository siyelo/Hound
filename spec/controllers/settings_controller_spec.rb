require 'spec_helper'

describe SettingsController do
  context "signed in user" do
    let(:user) { FactoryGirl.create(:user) }

    before :each do
      sign_in user
    end

    it "shows edit settings" do
      get 'edit'
      response.should be_success
    end

    describe "#update" do
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

      it "re-renders on failed update" do
        user.stub(:update_without_password).and_return false
        User.stub(:find).and_return(user)
        put :update, id: user.id, user: {'email' => 'g1@g.com'}
        flash[:alert].should == "Sorry, we couldn't update your settings."
        response.should render_template 'edit'
      end
    end

    describe "#update_password" do
      it "updates password" do
        put :update_password, id: user.id, user: { 'current_password' => 'testing',
          'password' => 'abcdef' }
        response.should redirect_to settings_path
        flash[:notice].should == "You have successfully updated your password."
      end

      it "re-renders on failed update" do
        user.stub(:update_with_password).and_return false
        User.stub(:find).and_return(user)
        put :update_password, id: user.id, user: { 'current_password' => 'testing',
          'password' => 'abcdef' }
        response.should render_template 'edit'
        flash[:alert].should == "Sorry, we couldn't update your password."
      end
    end
  end

  context "unauthenticated user" do
    it "redirects to sign in page when user not signed in" do
      get 'edit'
      response.should redirect_to(new_user_session_path)
    end
  end
end
