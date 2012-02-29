class SnoozeController < ApplicationController
  def edit
    @reminder = Reminder.find(params[:id])
    ## refactor me
    if @reminder && params[:token] && params[:duration]
      unless @reminder.snooze_for(params[:duration], params[:token])
        return render action: 'snooze_failed'
      end
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
