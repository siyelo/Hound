class SnoozeController < ApplicationController

  def edit
    @reminder = Reminder.find(params[:id])
    if @reminder && params[:token] && params[:duration]
      unless @reminder.snooze_for(params[:duration], params[:token])
        render action: 'snooze_failed' and return
      end
      render action: 'snooze_reminder'
    else
      render action: 'snooze_failed'
    end
  end

end
