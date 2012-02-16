class RemindersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @current_filter = ReminderFilter.current_filter(params[:filter])
    @reminders = ReminderFilter.filter_reminders(current_user.reminders, @current_filter)
    @groups = ReminderFilter.group_reminders(@reminders)
  end

  def edit
    @reminder = current_user.reminders.find_by_id(params[:id])
    redirect_to reminders_path unless @reminder
  end

  def update
    @reminder = current_user.reminders.find_by_id(params[:id])
    respond_to do |format|
      if @reminder.update_attributes(params[:reminder])
        @reminder.inform_other_recipients unless @reminder.cc.empty?
        flash[:notice] = "You have succesfully updated your reminder"
        format.json { render :json => { :success => :true } }
        format.html { redirect_to reminders_path }
      else
        flash[:notice] = "We have failed to update your reminder"
        format.html { render :action => "edit" }
        format.js  { render :json => @reminder.errors,
                       :status => :unprocessable_entity }
      end
    end
  end
end
