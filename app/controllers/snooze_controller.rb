class SnoozeController < ApplicationController
  def edit
    @reminder = Reminder.find_by_id(params[:id])
    if @reminder && @reminder.snooze_for(params[:duration], params[:token])
      render :snooze_reminder
    else
      render :snooze_failed
    end
  end

  # used to snooze reminders for other
  def show
    reminder = Reminder.find(params[:id])
    unless reminder.other_recipients.empty?
      Resque.enqueue(NotificationJob, reminder.id)
    end
    render :informed_of_snooze
  end
end
