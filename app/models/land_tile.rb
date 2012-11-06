class LandTile < ResourceTile
  include TreeHelperMethods
  include TreeGrowth
  include TreeValue
  include TreeHarvesting

  before_save :memoize_basal_area
  before_save :calculate_marten_suitability  #kevin wants to move this to an observer later, and that's aok with me

  Vacation = "vacation"
  Apartment = "apartment"
  SingleFamily = "single family"
  HomeTypes = [Vacation, Apartment, SingleFamily]

  def can_harvest?
    begin
      species_group
    rescue
      return false
    end

    true
  end
  
  def can_build?
    true
  end


  def tick
  end

  def can_bulldoze?
    true
  end

  def bulldoze!
    if can_bulldoze?
      World.transaction do
        clear_resources
        save!
      end
    else
      raise "This land cannot be bulldozed"
    end
  end




  def grow_trees! years = 1
    years.times { grow_trees }
    self.save!
  end


  def calculate_marten_suitability!(force = false)
    calculate_marten_suitability force
    save!
  end

  def calculate_marten_suitability(force = false)
    if force or trees_have_changed? or (self.small_tree_basal_area == nil) or (self.large_tree_basal_area == nil)
      memoize_basal_area force
    end
    
    return if (self.small_tree_basal_area == nil) or (self.large_tree_basal_area == nil)
    
    if MARTEN_SUITABLE_CLASS_CODES.include? self.landcover_class_code
      if small_tree_basal_area < large_tree_basal_area
        self.marten_suitability = 1
      else
        self.marten_suitability = 0
      end
    else self.marten_suitability = 0
    end
    #puts "Marten Suitability = #{marten_suitability}"
  end

  def memoize_basal_area(force = false)
    if trees_have_changed? or force
      size_array = self.collect_tree_size_counts
      self.small_tree_basal_area = calculate_basal_area(tree_sizes[0,5], size_array[0,5])
      self.large_tree_basal_area = calculate_basal_area(tree_sizes[6,12], size_array[6,12])
    end
  end


  api_accessible :resource, :extend => :resource_base do |template|
    template.add :primary_use
    template.add :zoning_code
#    template.add :people_density
#    template.add :housing_density
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
    template.add :housing_type
    template.add :harvest_area
    template.add :supported_saplings
    template.add :tree_type
    template.add :outpost
    template.add :marten_population
    template.add :vole_population
  end
end
