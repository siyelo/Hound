class RemindersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @current_filter = ReminderFilter.current_filter(params[:filter])
    @reminders = ReminderFilter.filter_reminders(current_user.reminders, @current_filter)
    @groups = ReminderFilter.group_reminders(@reminders)
  end

  def edit
    @reminder = current_user.reminders.find_by_id(params[:id])
    respond_to do |format|
      format.html { redirect_to reminders_path unless @reminder}
      format.js
    end
  end

  def update
    parse_reminder_time unless params[:reminder][:reminder_time]
    @reminder = current_user.reminders.find_by_id(params[:id])
    respond_to do |format|
      format.js
      if @reminder.update_attributes(params[:reminder])
        format.html { flash[:notice] = "You have succesfully updated your reminder";
                      redirect_to reminders_path }
      else
        format.html { flash[:alert] = "We have failed to update your reminder";
                      render :action => "edit" }
      end
    end
  end

  private

  def parse_reminder_time
    if params[:formatted_date] || params[:formatted_time]
      date = DateTime.parse params[:formatted_date] +' '+ params[:formatted_time]
      params[:reminder][:reminder_time] = date.change(offset: Time.zone.formatted_offset)
    end
  end
end
