class LandTile < ResourceTile  
  def can_be_clearcut?
    zoned_use == Verbiage[:zoned_uses][:logging]
  end
  
  def clearcut!
    if can_be_clearcut?
      World.transaction do
        megatile.owner.balance += estimated_lumber_value
        tree_density = 0.0
        tree_species = nil
        tree_size = 0.0
        save!
        puts "We just cleacut something! tree_size = #{tree_size}  tree_density = #{tree_density}"
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
  
  # #there doesn't seem to be a way to have extension follow inheritance
  # api_accessible :resource_base do |template|
  #   template.add :id
  #   template.add :x
  #   template.add :y
  #   template.add :type
  #   template.add :updated_at
  # end

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