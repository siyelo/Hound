require 'spec_helper'

describe RemindersController do
  context "signed in user" do
    it "redirects to sign in page when user not signed in" do
      get 'index'
      response.should redirect_to(new_user_session_path)
    end
  end

  context "signed in user" do
    let(:user) { Factory.create(:user) }
    let(:reminder) { Factory :reminder, fetched_mail: Factory(:fetched_mail, user: user) }

    before :each do
      sign_in user
    end

    it "should render the index" do
      get 'index'
      assigns(:reminder_filter).should_not be_nil
      response.should be_success
    end

    it "renders edit template" do
      get 'edit', id: reminder.id
      response.should render_template('edit')
    end

    it "cannot edit anothers reminder" do
      other_reminder = Factory :reminder

      lambda { get('edit', id: other_reminder.id) }.
        should raise_error(ActiveRecord::RecordNotFound)
    end

    it "can update reminder" do
      put 'update', id: reminder.id, reminder: { time: "3days" }
      flash[:notice].should == "You have successfully updated your reminder"
      response.should redirect_to(reminders_path)
    end

    it "cannot update reminder when errors" do
      put 'update', id: reminder.id, reminder: { time: "error" }
      flash[:alert].should == "We have failed to update your reminder"
      response.should render_template('edit')
    end

    it 'should destroy a reminder' do
      delete 'destroy', id: reminder.id
      response.should redirect_to(reminders_path)
    end
  end
end
