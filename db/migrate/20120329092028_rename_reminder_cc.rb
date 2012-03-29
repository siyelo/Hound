class RenameReminderCc < ActiveRecord::Migration
  def change
    change_table :reminders do |t|
      t.rename :cc, :other_recipients
      t.remove :is_bcc
    end
  end
end
