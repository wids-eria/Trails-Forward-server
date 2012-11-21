class ChangeContractHarvestVolumeDefault < ActiveRecord::Migration
  def change
    change_column :contracts, :volume_harvested_of_required_type, :integer, default: 0
  end
end
