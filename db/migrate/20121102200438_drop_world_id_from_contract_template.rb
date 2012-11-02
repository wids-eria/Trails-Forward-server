class DropWorldIdFromContractTemplate < ActiveRecord::Migration
  def change
    remove_column :contract_templates, :world_id
  end
end
