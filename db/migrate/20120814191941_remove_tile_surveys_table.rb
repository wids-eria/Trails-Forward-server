class RemoveTileSurveysTable < ActiveRecord::Migration
  def down
  end

  def up
    drop_table :tile_surveys
  end
end
