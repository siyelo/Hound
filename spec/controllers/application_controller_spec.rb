require 'spec_helper'

describe ApplicationController do
  controller do
    def index
      @zone = Time.zone
     render 'reminders/index'
    end
  end

  describe "handling timezone" do
    before :each do 
      @user = Factory :user, timezone: 'Harare'
      sign_in @user
    end
    
    it "should default timezone as UTC" do
      Time.zone.should == ActiveSupport::TimeZone.new('UTC')
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

