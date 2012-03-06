class AddSendingTimeToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :send_at, :datetime
  end
end

