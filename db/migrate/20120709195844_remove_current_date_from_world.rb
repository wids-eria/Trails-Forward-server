class RemoveCurrentDateFromWorld < ActiveRecord::Migration
  def up
    remove_column :worlds, :current_date
  end

  def down
    add_column :worlds, :current_date, :date
  end
end
