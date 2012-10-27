class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.integer :contract_template_id
      t.integer :world_id
      t.integer :player_id
      t.integer :month_started
      t.integer :month_ended
      t.boolean :ended
      t.boolean :successful
      t.boolean :on_time
      t.integer :volume_harvested_of_required_type

      t.timestamps
    end
  end
end
