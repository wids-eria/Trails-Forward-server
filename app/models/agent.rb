class Agent < ActiveRecord::Base
  belongs_to :resource_tile
  belongs_to :world

  def location= coords
    self.x = coords[0]
    self.y = coords[1]
  end

  def location
    [x, y]
  end

  def move distance
    if self.heading == 90
      self.x = (self.x + distance).round(3)
    elsif self.heading == 180
      self.y = (self.y - distance).round(3)
    else
      self.y = (self.y + distance).round(3)
    end
  end
end
