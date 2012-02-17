class CreateAliases < ActiveRecord::Migration
  def change
    create_table :email_aliases do |t|
      t.string :email
      t.integer :user_id
      t.timestamps
    end
  end
end
