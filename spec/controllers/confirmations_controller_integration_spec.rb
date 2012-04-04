require 'spec_helper'

describe ConfirmationsController do

  describe '#edit' do
    let(:user) { stub(:user) }

    it "renders failed template when token in invalid" do
      User.stub(:find_by_modify_token).with('sometoken').and_return(nil)

      get :disable, token: 'sometoken'
      response.should render_template 'failed'
    end

    it "should not change if the token is invalid" do
      User.stub(:find_by_modify_token).with('sometoken').and_return(user)
      user.should_receive(:disable_confirmation_emails).once.and_return(true)

      put :disable, :token => 'sometoken'
      response.should render_template 'success'
    end
  end
end
