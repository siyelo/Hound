class AddSendingTimeToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :reminder_time, :datetime
  end
end
