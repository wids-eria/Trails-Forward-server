class LandTile < ResourceTile
  TREE_MORTALITY_P = {
    shade_tolerant: [0.0336, 0, -0.0018, 0.0001, 0.00002],
    mid_tolerant: [0.0417, 0, -0.0033, 0.0001, 0],
    shade_intolerant: [0.0418, 0, -0.0009, 0, 0]
  }

  def can_clearcut?
    zoning_code != 255
  end

  def clearcut!
    if can_clearcut?
      World.transaction do
        megatile.owner.balance += estimated_lumber_value
        self.tree_density = 0.0
        self.land_cover_type = :barren
        self.tree_size = 0.0
        save!
      end
    else
      raise "This land cannot be clearcut"
    end
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

  def estimated_lumber_value
    td = (tree_density or 0)
    ts = (tree_size or 0)
    42 * td * ts
  end

  def grow_trees
    site_index = 60 # WAG because no data...

    (2..24).step(2).map do |diameter|
      species = species_group
      if species
        mortality_rate = determine_mortality_rate(diameter, species, site_index)
        self.send("num_#{diameter}_inch_diameter_trees=".to_sym, self.send("num_#{diameter}_inch_diameter_trees") * (1 - mortality_rate))
      end
    end

    self.save!
  end

  # Describes the yearly proportion of trees in a diameter class that die
  def determine_mortality_rate(diameter, species, site_index)
    # debugger if diameter = 8 && species == :shade_tolerant
    TREE_MORTALITY_P[species][0] +
      TREE_MORTALITY_P[species][1] * diameter +
      # TREE_MORTALITY_P[species][2] * basal_area +
      TREE_MORTALITY_P[species][3] * diameter**2 +
      TREE_MORTALITY_P[species][4] * site_index * diameter
  end

  def species_group
    case self.landcover_class_code
    when 41
      :shade_tolerant
    when 42, 95
      :mid_tolerant
    when 43
      :shade_intolerant
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
  end
end
