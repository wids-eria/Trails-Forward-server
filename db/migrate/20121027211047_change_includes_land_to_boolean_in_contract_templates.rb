class ChangeIncludesLandToBooleanInContractTemplates < ActiveRecord::Migration
  def change
    change_column :contract_templates, :includes_land, :boolean, default: false
  end

end
