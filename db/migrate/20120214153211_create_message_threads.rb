class CreateMessageThreads < ActiveRecord::Migration
  def change
    create_table :message_threads do |t|
      t.string :message_id
      t.string :parent_id
      t.timestamps
    end
  end
end
