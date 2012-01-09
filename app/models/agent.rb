require 'behavior/base'

class Agent < ActiveRecord::Base
  include Behavior::Base

  def self.dist
    @@dist ||= SimpleRandom.new
    @@dist.set_seed
    @@dist
  end

  def self.normal_dist std = 1, mean = 0
    self.dist.normal mean, std
  end

  property_set :settings do
    property :energy
  end

  belongs_to :resource_tile 
  belongs_to :world

  validates_presence_of :x
  validates_presence_of :y
  validates_presence_of :heading
  validates_presence_of :world

  before_validation :setup_resource_tile

  scope :for_types, lambda { |types| where(type: types.map{|t| t.to_s.classify}) }
  scope :for_type, lambda { |type| where(type: type.to_s.classify) }

  scope :in_square_range, lambda { |radius, x, y|
    x_min = x - radius
    x_max = x + radius
    y_min = y - radius
    y_max = y + radius
    where("x >= ? AND x <= ? AND y >= ? AND y <= ?", x_min, x_max, y_min, y_max)
  }

  scope :with_world_and_tile, include: [:world, :resource_tile]

  def max_view_distance
    10
  end

  def vector_to other
    Vector[other.x - self.x, other.y - self.y]
  end

  def turn degrees
    self.heading += degrees
  end

  def position_after_move distance
    offset_coordinates = Agent.calculate_offset_coordinates(self.heading, distance)
    new_x = (self.x + offset_coordinates[0]).round(2)
    new_y = (self.y + offset_coordinates[1]).round(2)
    new_heading = self.heading

    if new_x < 0 || new_x >= world.width
      if new_x < 0
        new_x = 0
      else
        new_x = world.width - 1
      end
      new_heading = (360 - self.heading)
    end

    if new_y < 0 || new_y >= world.height
      if new_y < 0
        new_y = 0
      else
        new_y = world.height - 1
      end
      new_heading = (180 - self.heading)
    end

    {location: [new_x, new_y], heading: new_heading}
  end

  def self.calculate_offset_coordinates heading, distance
    heading_in_radians = heading * (Math::PI / 180.0)
    x_offset = (distance * Math.sin(heading_in_radians)).round(2)
    y_offset = (distance * Math.cos(heading_in_radians)).round(2)
    [x_offset, y_offset]
  end

  def self.age! world
    world.agents.update_all('age = age + 1')
  end

  def tick!
    tick
    save! if changed?
    @litter
  end

  def tick
    @litter = []
    reproduce if reproduce?
    die if die?
    @litter
  end

private

  def setup_resource_tile
    return unless x && y && world
    self.resource_tile ||= world.resource_tile_at(x, y)
  end
end
