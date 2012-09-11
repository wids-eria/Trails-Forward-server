class AddSurveyFieldsToTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :can_be_surveyed, :boolean, :default => false
    add_column :resource_tiles, :is_surveyed, :boolean, :default => false
    add_column :resource_tiles, :bought_by_developer, :boolean, :default => false
    add_column :resource_tiles, :bought_by_timber_company, :boolean, :default => false
  end
end
