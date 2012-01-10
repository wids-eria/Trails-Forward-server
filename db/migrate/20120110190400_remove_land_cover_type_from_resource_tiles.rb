class RemoveLandCoverTypeFromResourceTiles < ActiveRecord::Migration
  def up
    remove_column :resource_tiles, :land_cover_type
  end

  def down
    add_column :resource_tiles, :land_cover_type, :string
  end
end
