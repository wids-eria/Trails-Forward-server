class LandTile < ResourceTile
  def can_clearcut?
    zoned_use == ResourceTile.verbiage[:zoned_uses][:logging]
  end

  def clearcut!
    if can_clearcut?
      World.transaction do
        megatile.owner.balance += estimated_lumber_value
        self.tree_density = 0.0
        self.tree_species = nil
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

  def self.grow_trees! world
    world.resource_tiles.with_trees.update_all('tree_density = tree_density + (((4 * POW(tree_density, 3)) - (8 * POW(tree_density, 2)) + (4 * tree_density)) * 0.5)')
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
    template.add :zoned_use
    template.add :people_density
    template.add :housing_density
    template.add :tree_density
    template.add :tree_species
    template.add :tree_size
    template.add :development_intensity
    template.add :imperviousness
  end
end
