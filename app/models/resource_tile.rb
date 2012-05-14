class ResourceTile < ActiveRecord::Base
  include ResourceTileZoning
  acts_as_api

  belongs_to :megatile
  belongs_to :world
  has_many :agents
  has_many :resources
  
  after_save :invalidate_megatile_cache

  def self.dist
    @@dist ||= SimpleRandom.new
    @@dist.set_seed
    @@dist
  end

  validates :zone_type, presence: true, inclusion: { in: valid_zone_types + valid_zone_types.map(&:to_s) }
  validates :landcover_class_code, presence: true, inclusion: { in: (1..255) }

  validates_uniqueness_of :x, :scope => [:y, :world_id]
  validates_uniqueness_of :y, :scope => [:x, :world_id]

  # todo: Add validations for land_cover_type, zoning_code, and primary_use to be sure that they're in one of the below

  scope :with_trees, where('tree_density > 0')

  scope :within_rectangle, lambda{|opts|
    min_x = opts[:x_min].to_i
    min_y = opts[:y_min].to_i
    max_x = opts[:x_max].to_i
    max_y = opts[:y_max].to_i

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
        :barren => 'Barren',
        :coniferous => "Coniferous",
        :cultivated_crops => 'Cultivated Crops',
        :deciduous => "Deciduous",
        :developed_high_intensity => 'Developed, High Intensity',
        :developed_low_intensity => 'Developed, Low Intensity',
        :developed_medium_intensity => 'Developed, Medium Intensity',
        :developed_open_space => 'Developed, Open Space',
        :dwarf_scrub => 'Dwarf Scrub',
        :emergent_herbaceous_wetland => 'Emergent Herbaceous Wetland',
        :excluded => 'Excluded',
        :forested_wetland => "Forested Wetland",
        :grassland_herbaceous => "Grassland/Herbaceous",
        :mixed => "Mixed",
        :open_water => 'Open Water',
        :pasture_hay => 'Pasture/Hay',
        :shrub_scrub => 'Shrub/Scrub',
        :unknown => "Unknown" },
      # :zoned_uses => {
        # :development => "Development",
        # :dev => "Development",
        # :agriculture => "Agriculture",
        # :ag => "Agriculture",
        # :logging => "Logging",
        # :park => "Park" },
      :primary_uses => {
        :pasture => "Agriculture/Pasture",
        :crops => "Agriculture/Cultivated Crops",
        :housing => "Housing",
        :logging => "Logging",
        :industry => "Industry" } }
  end


  def self.base_cover_type
    @base_cover_types ||= { 11 => :water,
                            21 => :developed,
                            22 => :developed,
                            23 => :developed,
                            24 => :developed,
                            31 => :barren,
                            41 => :forest,
                            42 => :forest,
                            43 => :forest,
                            51 => :herbaceous,
                            52 => :herbaceous,
                            71 => :herbaceous,
                            81 => :herbaceous,
                            82 => :cultivated_crops,
                            90 => :wetland,
                            95 => :wetland,
                            255 => :excluded }
  end

  def base_cover_type
    ResourceTile.base_cover_type[landcover_class_code]
  end

  def self.cover_types
    @cover_types ||= { 11 => :open_water,
                       21 => :developed_open_space,
                       22 => :developed_low_intensity,
                       23 => :developed_medium_intensity,
                       24 => :developed_high_intensity,
                       31 => :barren,
                       41 => :deciduous,
                       42 => :coniferous,
                       43 => :mixed,
                       51 => :dwarf_scrub,
                       52 => :shrub_scrub,
                       71 => :grassland_herbaceous,
                       81 => :pasture_hay,
                       82 => :cultivated_crops,
                       90 => :forested_wetland,
                       95 => :emergent_herbaceous_wetland,
                       255 => :excluded }
  end

  def self.cover_type_symbol class_code
    cover_types[class_code] || :unknown
  end

  def self.cover_type_number class_symbol
    cover_types.invert[class_symbol.to_sym] || raise("Cover type #{class_symbol} not found")
  end

  def location= coords
    self.x = coords[0]
    self.y = coords[1]
  end

  def location
    [x, y]
  end

  def center_location
    location.map {|x| x + 0.5}
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
    self.land_cover_type = :barren
    self.tree_size = nil
    self.development_intensity = nil
  end

  def land_cover_type
    ResourceTile.cover_type_symbol self.landcover_class_code
  end

  def land_cover_type= val
    self.landcover_class_code = ResourceTile.cover_type_number val
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

  def set_permitted_actions_method player
    if self.megatile.owner == player
      def self.permitted_actions
        self.owner_permitted_actions
      end
    end
  end

  api_accessible :resource_base do |template|
    template.add :id
    template.add :x
    template.add :y
    template.add :type
    template.add :base_cover_type
    template.add :permitted_actions
    template.add :zone_type
  end

  api_accessible :resource_actions do |template|
    template.add :id
    template.add :x
    template.add :y
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
    []
  end

  def <=> other
    self.location <=> other.location
  end

  def invalidate_megatile_cache
    megatile.invalidate_cache
  end
end
