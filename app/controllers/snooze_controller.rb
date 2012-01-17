class SnoozeController < ApplicationController
  require 'parser'

  def snooze_reminder
    initialize_snooze
    if @reminder && @token && @duration
      unless @reminder.snooze_for(@duration, @token)
        render :action => 'snooze_failed'
      end
    else
      render :action => 'snooze_failed'
    end
  end

  private

  def initialize_snooze
    @reminder = Reminder.find(params[:id])
    @token = params[:token]
    @duration = params[:duration]
  end
end
