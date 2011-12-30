class RenameTreeSpeciesAsLandCoverType < ActiveRecord::Migration
  def up
    rename_column :resource_tiles, :tree_species, :land_cover_type
  end

  def down
    rename_column :resource_tiles, :land_cover_type, :tree_species
  end
end
