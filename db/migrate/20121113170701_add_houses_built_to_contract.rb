class AddHousesBuiltToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :houses_built_of_required_type, :integer, :default => 0
  end
end
