class AddCleanedToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :cleaned, :boolean, default: false
  end
end
