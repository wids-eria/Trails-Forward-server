class AddYearCurrentToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :year_current, :integer, default: 0
  end
end
