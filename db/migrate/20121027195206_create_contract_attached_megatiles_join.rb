class CreateContractAttachedMegatilesJoin < ActiveRecord::Migration
  def change
    create_table :contract_attached_megatiles do |t|
      t.integer :contract_id
      t.integer :megatile_id
    end
  end
end
