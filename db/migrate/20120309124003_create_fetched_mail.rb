class CreateFetchedMail < ActiveRecord::Migration
  def change
    create_table :fetched_mails do |t|
      t.string :from
      t.string :to
      t.string :cc
      t.string :bcc
      t.string :subject
      t.string :body
      t.integer :user_id
      t.string :message_id
      t.string :in_reply_to
      t.timestamps
    end

    add_index :fetched_mails, :message_id, :unique => true
    add_index :fetched_mails, :user_id
  end
end
