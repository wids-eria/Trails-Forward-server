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
      self.x += distance
    else
      self.y += distance
    end
  end
end
