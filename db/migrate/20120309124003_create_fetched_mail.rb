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
      t.timestamps
    end
  end
end
