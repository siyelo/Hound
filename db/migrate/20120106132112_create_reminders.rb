class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      #TODO tidy up all migrations
      t.string :email
      t.string :subject
      t.string :body
      t.integer :fetched_mail_id
      t.timestamps
    end
  end
end
