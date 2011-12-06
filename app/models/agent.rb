class Agent < ActiveRecord::Base
  belongs_to :resource_tile
  belongs_to :world

  def max_view_distance
    10
  end

  def nearby_agents opts = {}
    opts = { radius: max_view_distance }.merge opts
    []
  end

  def location= coords
    self.x = coords[0]
    self.y = coords[1]
    self.resource_tile = world.resource_tile_at(self.x.floor, self.y.floor)
  end

  def location
    [x, y]
  end

  def move distance
    offset_coordinates = Agent.calculate_offset_coordinates(heading, distance)
    new_x = (self.x + offset_coordinates[0]).round(2)
    new_y = (self.y + offset_coordinates[1]).round(2)
    self.location = [new_x, new_y]
  end

  def self.calculate_offset_coordinates heading, distance
    heading_in_radians = heading * (Math::PI / 180)
    x_offset = (distance * Math.sin(heading_in_radians)).round(2)
    y_offset = (distance * Math.cos(heading_in_radians)).round(2)
    [x_offset, y_offset]
  end
end
