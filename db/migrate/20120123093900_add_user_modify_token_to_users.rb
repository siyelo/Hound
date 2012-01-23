class AddUserModifyTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :modify_token, :string
  end
end
