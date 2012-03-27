class CreateFetchedMail < ActiveRecord::Migration
  def change
    create_table :fetched_mails do |t|
      t.text :from
      t.text :to
      t.text :cc
      t.text :bcc
      t.text :subject
      t.text :body
      t.integer :user_id
      t.string :message_id
      t.string :in_reply_to
      t.timestamps
    end

    add_index :fetched_mails, :message_id, :unique => true
    add_index :fetched_mails, :user_id
  end
end
