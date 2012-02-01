class RemindersController < ApplicationController
  include RemindersHelper

  def index
    @reminders = current_user.reminders.upcoming_reminders
  end

  def edit
    @reminder = current_user.reminder.find(params[:id])
  end

  def update
    @reminder = current_user.reminder.find(params[:id])
    if @reminder.update_attributes(params)
      flash[:notice] = "You're a baller"
      redirect_to reminders_path
    else
      flash[:error] = "You're not a baller"
      render action: 'edit'
    end
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
