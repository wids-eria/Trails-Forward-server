class WaterTile < ResourceTile
  validate :should_not_have_land_properties
  validate :appropriate_zoning

  # there doesn't seem to be a way to have extension follow inheritance
  api_accessible :resource do |template|
    template.add :id
    template.add :x
    template.add :y
    template.add :tree_density
    template.add :land_cover_type
    template.add :tree_size
    template.add :type
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
