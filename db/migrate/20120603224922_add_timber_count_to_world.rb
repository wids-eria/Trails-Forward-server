class AddTimberCountToWorld < ActiveRecord::Migration
  def change
    add_column :worlds, :timber_count, :integer, :default => 0
  end
end
