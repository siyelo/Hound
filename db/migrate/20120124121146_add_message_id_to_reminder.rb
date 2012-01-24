class AddMessageIdToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :message_id, :string
  end
end
