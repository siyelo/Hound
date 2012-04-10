class AddTimeToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :time, :string
  end
end
