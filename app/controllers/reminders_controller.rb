require 'hound/services/reminder_mail_updater'

class RemindersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @reminder_filter = ReminderFilter.new(current_user.reminders, params[:filter])
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
    updater = Hound::ReminderMailUpdater.new
    updater.perform(current_user, params)
    @reminder_mail = updater.reminder_mail
    respond_to do |format|
      format.js
      format.html do
        if @reminder_mail.errors.empty?
          flash[:notice] = "You have successfully updated your reminder";
          redirect_to reminders_path
        else
          flash[:alert] = "We have failed to update your reminder";
          render :action => "edit"
        end
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

 end
