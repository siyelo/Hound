class AddSnoozeCountToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :snooze_count, :integer, default: 0
  end
end
