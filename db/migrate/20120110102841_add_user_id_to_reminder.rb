class AddUserIdToReminder < ActiveRecord::Migration
  def up
    add_column :reminders, :user_id, :integer
  end

  def down
    remove_column :reminders, :user_id
  end
end
