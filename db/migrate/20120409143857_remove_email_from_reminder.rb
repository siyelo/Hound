class RemoveEmailFromReminder < ActiveRecord::Migration
  def up
    remove_column :reminders, :email
  end

  def down
    add_column :reminders, :email, :string
  end
end
