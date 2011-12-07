class ResourceTile < ActiveRecord::Base
  acts_as_api

  belongs_to :megatile
  belongs_to :world
  has_many :agents

  # validates_uniqueness_of :x, :scope => [:y, :world_id]
  # validates_uniqueness_of :y, :scope => [:x, :world_id]

  # todo: Add validations for tree_species, zoned_use, and primary_use to be sure that they're in one of the below

  def self.verbiage
    { :tree_species => {
      :coniferous => "Coniferous",
      :deciduous => "Deciduous",
      :mixed => "Mixed" },
      :zoned_uses => {
        :development => "Development",
        :dev => "Development",
        :agriculture => "Agriculture",
        :ag => "Agriculture",
        :logging => "Logging",
        :park => "Park" },
        :primary_uses => {
          :pasture => "Agriculture/Pasture",
          :crops => "Agriculture/Cultivated Crops",
          :housing => "Housing",
          :logging => "Logging",
          :industry => "Industry" } }
  end

  def location= coords
    self.x = coords[0]
    self.y = coords[1]
  end

  def location
    [x, y]
  end

  def clear_resources
    self.primary_use = nil
    self.people_density = nil
    self.housing_density = nil
    self.tree_density = nil
    self.tree_species = nil
    self.tree_size = nil
    self.development_intensity = nil
  end

  def clear_resources!
    clear_resources
    save!
  end

  api_accessible :resource_base do |template|
    template.add :id
    template.add :x
    template.add :y
    template.add :type
    template.add :updated_at
  end

  api_accessible :resource, :extend => :resource_base do |template|
    # pass
  end

  def can_be_bulldozed?
    false
  end

  def can_be_clearcut?
    false
  end

  def estimated_value
    nil
  end
end
