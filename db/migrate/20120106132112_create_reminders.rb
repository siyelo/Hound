class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.string :email
      t.boolean :is_bcc, default: false
      t.string :cc
      t.integer :fetched_mail_id
      t.datetime :send_at
      t.boolean :delivered, :default => false, :null => false
      t.string :snooze_token
      t.integer :snooze_count, default: 0
      t.timestamps
    end

    add_index :reminders, :fetched_mail_id
  end
end
