class RemindersController < ApplicationController
  include RemindersHelper

  def index
    @reminders = current_user.reminders.upcoming_reminders
  end

  def edit
    @reminder = current_user.reminders.find(params[:id])
  end

  def update
    @reminder = current_user.reminders.find(params[:id])
    respond_to do |format|
      if @reminder.update_attributes(params[:reminder])
        format.json { render :json => { :success => :true } }
        format.html { redirect_to reminders_path }
      else
        format.html { render :action => "edit" }
        format.js  { render :json => @reminder.errors,
                       :status => :unprocessable_entity }
      end
    end
  end
end
