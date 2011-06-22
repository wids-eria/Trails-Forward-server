class LandTile < ResourceTile  
  def can_be_clearcut?
    zoned_use == Verbiage[:zoned_uses][:logging]
  end
  
  def clearcut!
    if can_be_clearcut?
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
  
  def can_be_bulldozed?
    true
  end
  
  def bulldoze!
    if can_be_bulldozed?
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
    if self.tree_size != nil
      self.tree_size = Math.log(1.10 * Math::E ** self.tree_size)
    end
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
