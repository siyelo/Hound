class AddNestedSetFieldsToMessageThread < ActiveRecord::Migration
  def change
    add_column :message_threads, :lft, :integer

    add_column :message_threads, :rgt, :integer

    add_column :message_threads, :depth, :integer

  end
end
