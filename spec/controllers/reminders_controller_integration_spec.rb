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

    it "should update a reminder as delivered" do
      put 'update', id: reminder.id, reminder_mail: { delivered: "true" }
      flash[:notice].should == "You have successfully updated your reminder"
      response.should redirect_to(reminders_path)
    end

    describe "ReminderMailUpdater" do
      before :each do
        @params = { "id" => "1", "reminder_mail" => { "send_at" => 'some date' },
          "controller"=>"reminders", "action"=>"update" }
        @updater = mock perform: true, reminder_mail: mock(errors: [])
        Hound::ReminderMailUpdater.stub(:new).and_return @updater
      end

      it "should instantiate new service using passed params" do
        Hound::ReminderMailUpdater.should_receive(:new)
        put :update, @params
      end

      it "should call the update service" do
        @updater.should_receive(:perform).with(user, @params).and_return true
        put :update, @params
        assigns[:reminder_mail].should_not be_nil
      end

      it "should populate a ReminderMail object with any errors" do
        @updater.stub(:perform).and_return false
        put :update, @params
        assigns[:reminder_mail].should_not be_nil
      end

      # some csrf weirdness with devise.
      # moving to an acceptance spec instead
      #
      # it "should render js on update" do
      #   @updater.should_receive(:perform).with(user, @params).and_return true
      #   xhr :put, :update, @params, :format => 'js'
      #   assigns[:reminder_mail].should_not be_nil
      # end

      # it "should render js on failed update" do
      #   @updater.stub(:perform).and_return false
      #   xhr :put, :update, @params, :format => 'js'
      #   assigns[:reminder_mail].should_not be_nil
      # end
    end

    it 'should destroy a reminder' do
      delete 'destroy', id: reminder.id
      response.should redirect_to(reminders_path)
    end
  end
end
