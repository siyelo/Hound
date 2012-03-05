class ChangeMessageThreadParentIdType < ActiveRecord::Migration
  def up
    remove_column :message_threads, :parent_id
    add_column :message_threads, :parent_id, :integer
  end

  def down
    remove_column :message_threads, :parent_id
    add_column :message_threads, :parent_id, :string
  end
end
