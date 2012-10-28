class CreateContractIncludedMegatilesJoin < ActiveRecord::Migration
  def change
    create_table :contract_included_megatiles, :id => false do |t|
      t.integer :contract_id, :null => false
      t.integer :megatile_id, :null => false
    end
  end
end
