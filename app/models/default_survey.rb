# When land isn't surveyed, return the peak growth of each tile that can grow
# things.
class DefaultSurvey < Survey
  def self.of(options = {})
    survey = Survey.new options
    harvestable_count = survey.megatile.resource_tiles.select do |rt|
      rt.can_clearcut?
    end.count

    default_counts = [272.437067809463, 99.994884114938, 45.5289670412543, 22.2937863557362, 11.0390612960499, 5.4378119957329, 2.75016842307342, 1.55739847629946, 1.07079856778977, 0.862134192795702, 0.722516967545298, 1.25089221979453]

    survey.num_2in_trees  = default_counts[0]  * harvestable_count
    survey.num_4in_trees  = default_counts[1]  * harvestable_count
    survey.num_6in_trees  = default_counts[2]  * harvestable_count
    survey.num_8in_trees  = default_counts[3]  * harvestable_count
    survey.num_10in_trees = default_counts[4]  * harvestable_count
    survey.num_12in_trees = default_counts[5]  * harvestable_count
    survey.num_14in_trees = default_counts[6]  * harvestable_count
    survey.num_16in_trees = default_counts[7]  * harvestable_count
    survey.num_18in_trees = default_counts[8]  * harvestable_count
    survey.num_20in_trees = default_counts[9]  * harvestable_count
    survey.num_22in_trees = default_counts[10] * harvestable_count
    survey.num_24in_trees = default_counts[11] * harvestable_count

    tile = LandTile.new landcover_class_code: 42 # for estimation methods

    survey.vol_2in_trees  = 0
    survey.vol_4in_trees  = 0
    survey.vol_6in_trees  = tile.estimated_tree_volume_for_size(6,  default_counts[2])  * harvestable_count
    survey.vol_8in_trees  = tile.estimated_tree_volume_for_size(8,  default_counts[3])  * harvestable_count
    survey.vol_10in_trees = tile.estimated_tree_volume_for_size(10, default_counts[4])  * harvestable_count
    survey.vol_12in_trees = tile.estimated_tree_volume_for_size(12, default_counts[5])  * harvestable_count
    survey.vol_14in_trees = tile.estimated_tree_volume_for_size(14, default_counts[6])  * harvestable_count
    survey.vol_16in_trees = tile.estimated_tree_volume_for_size(16, default_counts[7])  * harvestable_count
    survey.vol_18in_trees = tile.estimated_tree_volume_for_size(18, default_counts[8])  * harvestable_count
    survey.vol_20in_trees = tile.estimated_tree_volume_for_size(20, default_counts[9])  * harvestable_count
    survey.vol_22in_trees = tile.estimated_tree_volume_for_size(22, default_counts[10]) * harvestable_count
    survey.vol_24in_trees = tile.estimated_tree_volume_for_size(24, default_counts[11]) * harvestable_count
    
    survey
  end
end
