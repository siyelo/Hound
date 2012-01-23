class AddCcToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :cc, :string
  end
end
