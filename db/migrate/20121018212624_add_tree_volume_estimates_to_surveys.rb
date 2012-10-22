class AddTreeVolumeEstimatesToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :vol_2in_trees, :float
    add_column :surveys, :vol_4in_trees, :float
    add_column :surveys, :vol_6in_trees, :float
    add_column :surveys, :vol_8in_trees, :float
    add_column :surveys, :vol_10in_trees, :float
    add_column :surveys, :vol_12in_trees, :float
    add_column :surveys, :vol_14in_trees, :float
    add_column :surveys, :vol_16in_trees, :float
    add_column :surveys, :vol_18in_trees, :float
    add_column :surveys, :vol_20in_trees, :float
    add_column :surveys, :vol_22in_trees, :float
    add_column :surveys, :vol_24in_trees, :float
  end
end
