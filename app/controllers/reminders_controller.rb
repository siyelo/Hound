class RemindersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @reminder_filter = ReminderFilter.new(current_user, params[:filter])
  end

  def edit
    reminder = current_user.reminders.find(params[:id])
    @reminder_mail = ReminderMail.new(reminder) if reminder
    respond_to do |format|
      format.html { redirect_to reminders_path unless @reminder_mail}
      format.js
    end
  end

  def update
    parse_send_at!
    reminder = current_user.reminders.find params[:id]
    @reminder_mail = ReminderMail.new(reminder)
    respond_to do |format|
      format.js
      if @reminder_mail.update_attributes(params[:reminder_mail])
        format.html { flash[:notice] = "You have successfully updated your reminder";
                      redirect_to reminders_path }
      else
        format.html { flash[:alert] = "We have failed to update your reminder";
                      render :action => "edit" }
      end
    end
  end

  def destroy
    reminder = current_user.reminders.find(params[:id])
    respond_to do |format|
      format.js
      if reminder.destroy
        format.html { flash[:notice] = "Your reminder has been deleted";
                      redirect_to reminders_path }
      else
        format.html { flash[:alert] = "We could not delete your reminder";
                      redirect_to edit_reminder_path(reminder)}
      end
    end
  end

  private

  def parse_send_at!
    unless params[:reminder_mail][:send_at]
      if params[:formatted_date] || params[:formatted_time]
        date = DateTime.parse params.delete(:formatted_date) +' '+ params.delete(:formatted_time)
        params[:reminder_mail][:send_at] = date.change(offset: Time.zone.formatted_offset)
      end
    end
  end
end
