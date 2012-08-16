class Survey < ActiveRecord::Base
  belongs_to :megatile
  belongs_to :player

  def self.of(options = {})
    survey = Survey.new options
    survey.num_2in_trees  = survey.megatile.resource_tiles.collect(&:num_2_inch_diameter_trees ).sum
    survey.num_4in_trees  = survey.megatile.resource_tiles.collect(&:num_4_inch_diameter_trees ).sum
    survey.num_6in_trees  = survey.megatile.resource_tiles.collect(&:num_6_inch_diameter_trees ).sum
    survey.num_8in_trees  = survey.megatile.resource_tiles.collect(&:num_8_inch_diameter_trees ).sum
    survey.num_10in_trees = survey.megatile.resource_tiles.collect(&:num_10_inch_diameter_trees).sum
    survey.num_12in_trees = survey.megatile.resource_tiles.collect(&:num_12_inch_diameter_trees).sum
    survey.num_14in_trees = survey.megatile.resource_tiles.collect(&:num_14_inch_diameter_trees).sum
    survey.num_16in_trees = survey.megatile.resource_tiles.collect(&:num_16_inch_diameter_trees).sum
    survey.num_18in_trees = survey.megatile.resource_tiles.collect(&:num_18_inch_diameter_trees).sum
    survey.num_20in_trees = survey.megatile.resource_tiles.collect(&:num_20_inch_diameter_trees).sum
    survey.num_22in_trees = survey.megatile.resource_tiles.collect(&:num_22_inch_diameter_trees).sum
    survey.num_24in_trees = survey.megatile.resource_tiles.collect(&:num_24_inch_diameter_trees).sum
    survey
  end
end
