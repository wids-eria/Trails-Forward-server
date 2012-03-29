class CreateTileSurveys < ActiveRecord::Migration
  def change
    create_table :tile_surveys do |t|
      t.float :poletimber_value
      t.float :sawtimber_value

      t.timestamps
    end
  end
end
