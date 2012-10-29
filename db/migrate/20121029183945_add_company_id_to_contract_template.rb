class AddCompanyIdToContractTemplate < ActiveRecord::Migration
  def change
    add_column :contract_templates, :company_id, :integer
  end
end
