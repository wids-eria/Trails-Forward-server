class AddSurveyAndOutpostRequestToResourceTile < ActiveRecord::Migration
  def change
    add_column :resource_tiles, :outpost_requested, :boolean, :default => false
    add_column :resource_tiles, :survey_requested, :boolean, :default => false
  end
end
