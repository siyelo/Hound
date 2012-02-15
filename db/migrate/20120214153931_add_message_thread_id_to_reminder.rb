class AddMessageThreadIdToReminder < ActiveRecord::Migration
  def change
    add_column :reminders, :message_thread_id, :integer
    add_column :reminders, :sent_to, :string
  end
end
