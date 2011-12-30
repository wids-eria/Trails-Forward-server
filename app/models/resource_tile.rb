class ResourceTile < ActiveRecord::Base
  acts_as_api

  belongs_to :megatile
  belongs_to :world
  has_many :agents

  # validates_uniqueness_of :x, :scope => [:y, :world_id]
  # validates_uniqueness_of :y, :scope => [:x, :world_id]

  # todo: Add validations for land_cover_type, zoned_use, and primary_use to be sure that they're in one of the below

  scope :with_trees, where('tree_density > 0')

  scope :within_rectangle, lambda{|opts|
    min_x = opts[:x].to_i
    min_y = opts[:y].to_i
    width = opts[:width].to_i
    height = opts[:height].to_i
    max_x = min_x + width - 1
    max_y = min_y + height - 1

    where(x: min_x..max_x, y: min_y..max_y)
  }
  # scope :for_types, lambda { |types| where(type: types.map{|t| t.to_s.classify}) }

  scope :with_agents, include: [:agents]

  scope :in_square_range, lambda { |radius, x, y|
    x_min = (x - radius).floor
    y_min = (y - radius).floor
    if radius == 0
      where("x = ? AND y= ?", x_min, y_min)
    else
      x_max = (x + radius).ceil
      y_max = (y + radius).ceil
      where("x >= ? AND x < ? AND y >= ? AND y < ?", x_min, x_max, y_min, y_max)
    end
  }

  def self.landcover_description landcover_code
    cover_type_sym = ResourceTile.cover_type_symbol(landcover_code)
    self.verbiage[:land_cover_type][cover_type_sym]
  end

  def self.verbiage
    { :land_cover_type => {
        :coniferous => "Coniferous",
        :deciduous => "Deciduous",
        :mixed => "Mixed",
        :forested_wetland => "Forested Wetland",
        :dwarf_scrub => 'Dwarf Scrub',
        :shrub_scrub => 'Shrub/Scrub',
        :grassland_herbaceous => "Grassland/Herbaceous",
        :unknown => "Unknown" },
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

  def self.cover_type_symbol class_code
    case class_code
    when 41 then :deciduous
    when 42 then :coniferous
    when 43 then :mixed
    when 51 then :dwarf_scrub
    when 52 then :shrub_scrub
    when 71 then :grassland_herbaceous
    when 90 then :forested_wetland
    else :unknown
    end
  end

  def location= coords
    self.x = coords[0]
    self.y = coords[1]
  end

  def location
    [x, y]
  end

  def zone_allowed? zone
    not disallowed_zoned_uses.include? zone
  end

  def disallowed_zoned_uses
    []
  end

  def clear_resources
    self.primary_use = nil
    self.people_density = nil
    self.housing_density = nil
    self.tree_density = nil
    self.land_cover_type = nil
    self.tree_size = nil
    self.development_intensity = nil
  end

  def clear_resources!
    clear_resources
    save!
  end

  def tick
    raise NotImplementedError
  end

  def tick!
    tick
    save! if changed?
  end

  api_accessible :resource_base do |template|
    template.add :id
    template.add :x
    template.add :y
    template.add :type
    template.add :permitted_actions
  end

  api_accessible :resource, :extend => :resource_base do |template|
    # pass
  end

  def can_bulldoze?
    false
  end

  def can_clearcut?
    false
  end

  def clearcut!

  end

  def bulldoze!

  end

  def estimated_value
    nil
  end

  def all_actions
    %w(bulldoze clearcut)
  end

  def permitted_actions player = nil
    return non_owner_permitted_actions unless player
    if megatile.owner == player
      owner_permitted_actions
    else
      non_owner_permitted_actions
    end
  end

  def owner_permitted_actions
    self.all_actions.select {|action| send("can_#{action}?") }
  end

  def non_owner_permitted_actions
    self.all_actions.select {|action| send("can_#{action}?") }.map do |action|
      "request_#{action}"
    end
  end

  def <=> other
    self.location <=> other.location
  end
end
