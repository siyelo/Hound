class ChangeDeliveredColumnDefaultBecauseSqliteSucksAss < ActiveRecord::Migration
  def change
    change_column :reminders, :delivered, :boolean, :default => false, :null => false
  end
end
