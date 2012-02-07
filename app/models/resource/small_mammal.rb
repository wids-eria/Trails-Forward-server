class SmallMammal < Resource
  def grow
    small_mammal_growth_rate = 1.4
    small_mammal_carrying_capacity = 50
    small_mammal_increment = small_mammal_growth_rate * value * (1 - (value / small_mammal_carrying_capacity))
    self.value = self.value + small_mammal_increment
  end

  def set_carrying_capacity
    if resource_tile.land_cover_type = :forest
      50
  end

  def set_growth_rate
    if sesource_tile.land_cover_type = :forest
      1.4

end

# mammal = SmallMammal.new
# mammal.value = 5
# mammal.grow
# assert here
