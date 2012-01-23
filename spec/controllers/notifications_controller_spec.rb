require 'spec_helper'

describe NotificationsController do

  describe 'notifications' do
    before :each do
      @user = Factory :user
    end

    it "should not change if the token is invalid" do
      put :edit, id: @user.id
      response.should render_template 'failed'
    end

    it "should not change confirmation email status if token is invalid" do
      put :edit, id: @user.id
      @user.reload.confirmation_email.should be_true
      response.should render_template 'failed'
    end

    it "should set the confirmation email to false" do
      put :edit, id: @user.id, token: @user.modify_token
      @user.reload.confirmation_email.should be_false
      response.should render_template 'success'
    end
  end
end
