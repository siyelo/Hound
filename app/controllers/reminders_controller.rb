class RemindersController < ApplicationController
  include RemindersHelper

  def index
    @reminders = filter_reminders(params[:filter])
  end

  def edit
    @reminder = current_user.reminders.find(params[:id])
  end

  def update
    @reminder = current_user.reminders.find(params[:id])
    respond_to do |format|
      if @reminder.update_attributes(params[:reminder])
        @reminder.inform_other_recipients unless @reminder.cc.empty?
        flash[:notice] = "You have succesfully updated your reminder"
        format.json { render :json => { :success => :true } }
        format.html { redirect_to reminders_path }
      else
        flash[:notice] = "You have failed to update your reminder"
        format.html { render :action => "edit" }
        format.js  { render :json => @reminder.errors,
                       :status => :unprocessable_entity }
      end
    end
  end
end
