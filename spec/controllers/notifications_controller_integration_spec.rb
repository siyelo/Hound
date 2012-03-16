require 'spec_helper'

describe NotificationsController do

  describe '#edit' do
    let(:user) { stub(:user) }

    it "renders failed template when token in invalid" do
      User.stub(:find).with('1').and_return(user)
      user.should_receive(:disable_confirmation_emails).once.
           with(nil).and_return(false)

      put :edit, id: '1'
      response.should render_template 'failed'
    end

    it "should not change if the token is invalid" do
      User.stub(:find).with('1').and_return(user)
      user.should_receive(:disable_confirmation_emails).once.
           with('correct token').and_return(true)
      put :edit, id: '1', :token => 'correct token'
      response.should render_template 'success'
    end
  end
end
