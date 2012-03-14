class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      #TODO tidy up all migrations
      t.string :email
      t.string :body
      t.boolean :is_bcc, default: false
      t.integer :fetched_mail_id
      t.timestamps
    end
  end
end
