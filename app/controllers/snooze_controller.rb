class SnoozeController < ApplicationController
  def edit
    @reminder = Reminder.find_by_id(params[:id])
    if @reminder && @reminder.snooze_for(params[:duration], params[:token])
      render action: 'snooze_reminder'
    else
      render action: 'snooze_failed'
    end
  end

  # used to snooze reminders for other
  def show
    reminder = Reminder.find(params[:id])
    Queuer.add_to_snooze_to_notification_queue(reminder)
    render action: 'informed_of_snooze'
  end
end
