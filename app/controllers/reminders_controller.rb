class RemindersController < ApplicationController

  def index
    puts "me"
    @reminders = current_user.reminders
  end
end
