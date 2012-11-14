class AddNameToContractTemplates < ActiveRecord::Migration
  def change
    add_column :contract_templates, :name, :string
  end
end
