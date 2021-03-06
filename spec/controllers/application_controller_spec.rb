require 'spec_helper'

describe ApplicationController do

  # mock controller with index action
  controller do
    def index
      @zone = Time.zone
      render text: 'ok'
    end
  end

  describe "handling timezone" do
    before :each do
      @user = FactoryGirl.create :user, timezone: 'Harare'
      sign_in @user
    end

    it "should set the user timezone during request" do
      get :index
      assigns(:zone).should == ActiveSupport::TimeZone.new('Harare')
    end

    it "should revert to default timezone after request" do
      get :index
      Time.zone.should == ActiveSupport::TimeZone.new('UTC')
    end
  end
end
