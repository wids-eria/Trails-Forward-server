class Survey < ActiveRecord::Base
  acts_as_api

  belongs_to :megatile
  belongs_to :player

  def self.cost
    25
  end

  def self.of(options = {})
    survey = Survey.new options
    tiles_with_trees = []
    tiles_with_trees = survey.megatile.resource_tiles.select do |rt|
      rt.can_harvest? && rt.respond_to?(:estimated_tree_volume_for_size)
    end

    survey.num_2in_trees  = tiles_with_trees.collect(&:num_2_inch_diameter_trees ).sum
    survey.num_4in_trees  = tiles_with_trees.collect(&:num_4_inch_diameter_trees ).sum
    survey.num_6in_trees  = tiles_with_trees.collect(&:num_6_inch_diameter_trees ).sum
    survey.num_8in_trees  = tiles_with_trees.collect(&:num_8_inch_diameter_trees ).sum
    survey.num_10in_trees = tiles_with_trees.collect(&:num_10_inch_diameter_trees).sum
    survey.num_12in_trees = tiles_with_trees.collect(&:num_12_inch_diameter_trees).sum
    survey.num_14in_trees = tiles_with_trees.collect(&:num_14_inch_diameter_trees).sum
    survey.num_16in_trees = tiles_with_trees.collect(&:num_16_inch_diameter_trees).sum
    survey.num_18in_trees = tiles_with_trees.collect(&:num_18_inch_diameter_trees).sum
    survey.num_20in_trees = tiles_with_trees.collect(&:num_20_inch_diameter_trees).sum
    survey.num_22in_trees = tiles_with_trees.collect(&:num_22_inch_diameter_trees).sum
    survey.num_24in_trees = tiles_with_trees.collect(&:num_24_inch_diameter_trees).sum

    survey.vol_2in_trees  = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size( 2, rt.num_2_inch_diameter_trees) }.sum
    survey.vol_4in_trees  = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size( 4, rt.num_4_inch_diameter_trees) }.sum
    survey.vol_6in_trees  = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size( 6, rt.num_6_inch_diameter_trees) }.sum
    survey.vol_8in_trees  = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size( 8, rt.num_8_inch_diameter_trees) }.sum
    survey.vol_10in_trees = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size(10, rt.num_10_inch_diameter_trees)}.sum
    survey.vol_12in_trees = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size(12, rt.num_12_inch_diameter_trees)}.sum
    survey.vol_14in_trees = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size(14, rt.num_14_inch_diameter_trees)}.sum
    survey.vol_16in_trees = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size(16, rt.num_16_inch_diameter_trees)}.sum
    survey.vol_18in_trees = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size(18, rt.num_18_inch_diameter_trees)}.sum
    survey.vol_20in_trees = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size(20, rt.num_20_inch_diameter_trees)}.sum
    survey.vol_22in_trees = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size(22, rt.num_22_inch_diameter_trees)}.sum
    survey.vol_24in_trees = tiles_with_trees.collect{|rt| rt.estimated_tree_volume_for_size(24, rt.num_24_inch_diameter_trees)}.sum

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
    template.add :vol_2in_trees
    template.add :vol_4in_trees
    template.add :vol_6in_trees
    template.add :vol_8in_trees
    template.add :vol_10in_trees
    template.add :vol_12in_trees
    template.add :vol_14in_trees
    template.add :vol_16in_trees
    template.add :vol_18in_trees
    template.add :vol_20in_trees
    template.add :vol_22in_trees
    template.add :vol_24in_trees
    template.add :created_at
    template.add :updated_at
  end

end
