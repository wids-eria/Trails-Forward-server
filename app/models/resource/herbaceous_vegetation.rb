class HerbaceousVegetation < Resource
  def self.grow! world
    if growth_smoothing > 0
      resources_in_world(world).update_all("value = (SQRT(value) + (#{growth_smoothing - 1} * value)) / #{growth_smoothing}")
    else
      resources_in_world(world).update_all("value = SQRT(value)")
    end
  end

  def self.growth_smoothing
    100
  end
end
