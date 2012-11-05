class RemoveTimberCountFromWorld < ActiveRecord::Migration
  def up
    remove_column :worlds, :timber_count
  end

  def down
    add_column :worlds, :timber_count, :integer, :default => 0
  end
end
