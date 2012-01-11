class AddTreeDiametersToResourceTiles < ActiveRecord::Migration
  def up
    add_column :resource_tiles, :num_2_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_4_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_6_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_8_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_10_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_12_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_14_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_16_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_18_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_20_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_22_inch_diameter_trees, :integer
    add_column :resource_tiles, :num_24_inch_diameter_trees, :integer
  end

  def down
    remove_column :resource_tiles, :num_24_inch_diameter_trees
    remove_column :resource_tiles, :num_22_inch_diameter_trees
    remove_column :resource_tiles, :num_20_inch_diameter_trees
    remove_column :resource_tiles, :num_18_inch_diameter_trees
    remove_column :resource_tiles, :num_16_inch_diameter_trees
    remove_column :resource_tiles, :num_14_inch_diameter_trees
    remove_column :resource_tiles, :num_12_inch_diameter_trees
    remove_column :resource_tiles, :num_10_inch_diameter_trees
    remove_column :resource_tiles, :num_8_inch_diameter_trees
    remove_column :resource_tiles, :num_6_inch_diameter_trees
    remove_column :resource_tiles, :num_4_inch_diameter_trees
    remove_column :resource_tiles, :num_2_inch_diameter_trees
  end
end
