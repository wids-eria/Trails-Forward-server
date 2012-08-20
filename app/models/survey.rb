class Survey < ActiveRecord::Base
  acts_as_api

  belongs_to :megatile
  belongs_to :player

  def self.cost
    25
  end

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

  api_accessible :survey do |template|
    template.add :id
    template.add :player_id
    template.add :num_2in_trees
    template.add :num_4in_trees
    template.add :num_6in_trees
    template.add :num_8in_trees
    template.add :num_10in_trees
    template.add :num_12in_trees
    template.add :num_14in_trees
    template.add :num_16in_trees
    template.add :num_18in_trees
    template.add :num_20in_trees
    template.add :num_22in_trees
    template.add :num_24in_trees
    template.add :created_at
    template.add :updated_at
  end
end
