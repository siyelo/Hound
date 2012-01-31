class RemindersController < ApplicationController
  include RemindersHelper

  def index
    @reminders = Reminder.upcoming_reminders_for(current_user)
  end
end
