class LandTile < ResourceTile
  include TreeHelperMethods
  include TreeGrowth
  include TreeValue
  include TreeHarvesting

  before_save :memoize_basal_area
  before_save :calculate_marten_suitability  #kevin wants to move this to an observer later, and that's aok with me

  def can_clearcut?
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

  def clearcut!
    results = clearcut
    save!
    return results
  end

  def diameter_limit_cut! options
    results = diameter_limit_cut options
    save!
    return results
  end

  def partial_selection_cut! options
    results = partial_selection_cut options
    save!
    return results
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


  def estimated_value
    # MatLab equation:
    # lntotalprice=bdum.*coeff(1,1)+lntotalacres.*coeff(1,2)+lntot2.*coeff(1,3)+lnfrontage.*coeff(1,4)+lnf2.*coeff(1,5)+lnlakesize.*coeff(1,6);
    # lntotalprice=lntotalprice+lnlake2.*coeff(1,7)+sone.*coeff(1,8)+stwo.*coeff(1,9)+szero.*coeff(1,10)+10.24;
    # totalprice=exp(lntotalprice);

    coeff=[1.113921,0.2421629,0.0017476,0.0879644,0.0144558,0.249173,0.0058711,-0.046306,0.0342448,0.0038761,10.24675];

    bdum = 0.0
    if self.housing_density != nil && self.housing_density != 0
      bdum = 1.0
    end

    lntotalacres = 1.0
    lntot2 = lntotalacres ** 2

    lnfrontage = 0.0
    if self.frontage != nil
      lnfrontage = self.frontage
    end
    lnf2 = lnfrontage ** 2

    lnlakesize = 0.0
    if self.lakesize != nil
      lnlakesize = self.lakesize
    end
    lnlake2 = lnlakesize ** 2

    sone = stwo = szero = 0.0
    case self.soil
    when 0
      szero = 1.0
    when 1
      sone = 1.0
    when 2
      stwo = 1.0
    end

    lntotalprice = bdum*coeff[0]+lntotalacres*coeff[1]+lntot2*coeff[2]+lnfrontage*coeff[3]+lnf2*coeff[4]+lnlakesize*coeff[5]+lnlake2*coeff[6]+sone*coeff[7]+stwo*coeff[8]+szero*coeff[9]+10.24;
    totalprice = Math.exp(lntotalprice)
    totalprice
  end


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
end
