class WaterTile < ResourceTile
  validate :should_not_have_land_properties
  validate :appropriate_zoning

  # there doesn't seem to be a way to have extension follow inheritance
  #api_accessible :resource do |template|
  #  template.add :id
  #  template.add :x
  #  template.add :y
  #  template.add :tree_density
  #  template.add :land_cover_type
  #  template.add :tree_size
  #  template.add :type
  #end

  api_accessible :resource, :extend => :resource_base do |template|
    template.add :primary_use
    template.add :zoning_code
    template.add :people_density
    template.add :housing_density
    template.add :tree_density
    template.add :land_cover_type
    template.add :tree_size
    template.add :development_intensity
    template.add :imperviousness
    template.add :num_2_inch_diameter_trees
    template.add :num_4_inch_diameter_trees
    template.add :num_6_inch_diameter_trees
    template.add :num_8_inch_diameter_trees
    template.add :num_10_inch_diameter_trees
    template.add :num_12_inch_diameter_trees
    template.add :num_14_inch_diameter_trees
    template.add :num_16_inch_diameter_trees
    template.add :num_18_inch_diameter_trees
    template.add :num_20_inch_diameter_trees
    template.add :num_22_inch_diameter_trees
    template.add :num_24_inch_diameter_trees
    template.add :housing_capacity
    template.add :housing_occupants
    template.add :harvest_area
    template.add :supported_saplings
    template.add :tree_type
    template.add :outpost
    template.add :marten_population
    template.add :vole_population
  end
  def tick

  end

  private

  def should_not_have_land_properties
    errors.add(:people_density, "illegal for water tiles") unless [nil,0,0.0].include? people_density
    errors.add(:housing_density, "illegal for water tiles") unless [nil,0,0.0].include? housing_density
    errors.add(:development_intensity, "illegal for water tiles") unless [nil,0,0.0].include? development_intensity
    errors.add(:tree_density, "illegal for water tiles") unless [nil,0,0.0].include? tree_density
    errors.add(:tree_size, "illegal for water tiles") unless [nil,0,0.0].include? tree_size
  end

  def appropriate_zoning
    errors.add(:zoning_code, "disallowed zoning") unless zoning_code == 255
  end

end
