class OtherRecipientsToTextField < ActiveRecord::Migration
  def up
    change_column :reminders, :other_recipients, :text
  end

  def down
    change_column :reminders, :other_recipients, :string
  end
end
