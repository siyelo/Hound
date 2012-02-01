class RemindersController < ApplicationController
  include RemindersHelper

  def index
    @reminders = Reminder.upcoming_reminders_for(current_user)
  end

  def update
    @reminder = Reminder.find(params[:id])

    respond_to do |format|
      if @reminder.update_attributes(params[:reminder])
        format.json { render :json => { :success => :true } }
        format.html { render :action => "index" }
      else
        format.html { render :action => "edit" }
        format.js  { render :json => @reminder.errors,
                       :status => :unprocessable_entity }

      end
    end

  end
end
