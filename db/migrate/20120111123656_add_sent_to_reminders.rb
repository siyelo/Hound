class AddSentToReminders < ActiveRecord::Migration
  def change
    add_column :reminders, :delivered, :boolean, default: false
  end
end
