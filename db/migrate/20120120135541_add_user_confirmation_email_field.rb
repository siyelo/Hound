class AddUserConfirmationEmailField < ActiveRecord::Migration
  def change
    add_column :users, :confirmation_email, :boolean, default: true
  end
end
