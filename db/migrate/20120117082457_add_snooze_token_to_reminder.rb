class AddSnoozeTokenToReminder < ActiveRecord::Migration
  def up
    add_column :reminders, :snooze_token, :string
  end

  def down
    remove_column :reminders, :snooze_token
  end
end
