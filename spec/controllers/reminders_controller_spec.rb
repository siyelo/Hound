require 'spec_helper'

describe RemindersController do
  include Devise::TestHelpers

  it "should redirect to sign-in page if user not authenticated" do
    get 'index'
    response.should redirect_to(new_user_session_path)
  end

  context "authenticated" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
    end

    it "should render the index" do
      get 'index'
      assigns(:reminder_filter).should_not be_nil
      response.should be_success
    end

    it "should render the edit for a reminder that does exist" do
      reminder = Factory :reminder, fetched_mail: Factory(:fetched_mail, user: @user)
      get 'edit', id: reminder.id
      response.should render_template('edit')
    end

    it "should redirect to index when trying to edit a reminder that doesnt belong to you" do
      reminder = Factory :reminder
      get 'edit', id: reminder.id
      response.should redirect_to(reminders_path)
    end

    it 'should redirect to index when trying to edit a reminder that doesnt exist' do
      get 'edit'
      response.should redirect_to(reminders_path)
    end

    it 'should destroy a reminder' do
      reminder = Factory :reminder, fetched_mail: Factory(:fetched_mail, user: @user)
      delete 'destroy', id: reminder.id
      response.should redirect_to(reminders_path)
    end

    it "should update a reminder as complete" do
      reminder = Factory :reminder, fetched_mail: Factory(:fetched_mail, user: @user)
      put 'update', id: reminder.id, reminder_mail: { delivered: "true" }
      flash[:notice].should == "You have successfully updated your reminder"
      response.should redirect_to(reminders_path)
    end
  end
end
