class CreateContractTemplates < ActiveRecord::Migration
  def change
    create_table :contract_templates do |t|
      t.integer :world_id
      t.string :codename
      t.string :role
      t.string :difficulty
      t.integer :points_required_to_unlock
      t.integer :points
      t.integer :dollars
      t.integer :deadline
      t.text :description
      t.text :acceptance_message
      t.text :complete_message
      t.text :late_message
      t.boolean :includes_land
      t.integer :volume_required
      t.string :wood_type
      t.integer :acres_added_required
      t.integer :acres_developed_required
      t.string :home_type

      t.timestamps
    end
  end
end
