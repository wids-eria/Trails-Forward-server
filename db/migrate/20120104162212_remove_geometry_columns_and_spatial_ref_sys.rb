class RemoveGeometryColumnsAndSpatialRefSys < ActiveRecord::Migration
  def up
    drop_table :geometry_columns
    drop_table :spatial_ref_sys
  end

  def down
    raise IrreversibleMigration
  end
end
