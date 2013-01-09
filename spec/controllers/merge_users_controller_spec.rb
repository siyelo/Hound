require 'spec_helper'

describe MergeUsersController do
  let(:user) { Factory.create(:user) }
  let(:secondary_user) { Factory.create(:user) }

  describe "create" do
    before :each do
      sign_in user
      @params = { secondary_email: secondary_user.email, secondary_password: 'testing' }
      @merger = mock perform: true
      Hound::UserMerger.stub(:new).and_return @merger
    end

    it "should instantiate new service using passed params" do
      Hound::UserMerger.should_receive(:new)
      post :create, @params
    end

    it "should call the merger service" do
      @merger.should_receive(:perform).with(user, secondary_user).and_return true
      post :create, @params
    end

    it "should not call the merger service if user isn't found" do
      Hound::UserMerger.should_not_receive(:new)
      post :create
    end
  end
end
