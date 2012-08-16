class AddTreesToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :num_2in_trees, :float, default: 0.0
    add_column :surveys, :num_4in_trees, :float, default: 0.0
    add_column :surveys, :num_6in_trees, :float, default: 0.0
    add_column :surveys, :num_8in_trees, :float, default: 0.0
    add_column :surveys, :num_10in_trees, :float, default: 0.0
    add_column :surveys, :num_12in_trees, :float, default: 0.0
    add_column :surveys, :num_14in_trees, :float, default: 0.0
    add_column :surveys, :num_16in_trees, :float, default: 0.0
    add_column :surveys, :num_18in_trees, :float, default: 0.0
    add_column :surveys, :num_20in_trees, :float, default: 0.0
    add_column :surveys, :num_22in_trees, :float, default: 0.0
    add_column :surveys, :num_24in_trees, :float, default: 0.0
  end
end
