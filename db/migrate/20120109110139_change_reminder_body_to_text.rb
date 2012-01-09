class ChangeReminderBodyToText < ActiveRecord::Migration
  def up
    change_column :reminders, :body, :text
  end

  def down
    change_column :reminders, :body, :string
  end
end
