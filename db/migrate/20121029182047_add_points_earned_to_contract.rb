class AddPointsEarnedToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :points_earned, :integer
  end
end
