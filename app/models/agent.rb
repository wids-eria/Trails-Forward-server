class Agent < ActiveRecord::Base
  has_geom :geom => :point

  belongs_to :resource_tile
  belongs_to :world

  after_create :setup_geom

  scope :for_types, lambda { |types| where(type: types.map{|t| t.to_s.classify}) }
  scope :for_type, lambda { |type| where(type: type.to_s.classify) }

  def max_view_distance
    10
  end

  def nearby_agents opts = {}
    opts = {}.merge opts
    opts[:radius] = [opts[:radius], max_view_distance].compact.min

    scope = Agent.scoped
    scope = scope.for_types(opts[:types]) if opts[:types]
    scope.all_dwithin(geom, opts[:radius]).reject{|a| a.id == id}
  end

  def nearby_peers opts = {}
    nearby_agents(opts.merge({types: [self.class]}))
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

  private

  def setup_geom
    return unless x && y
    self.geom = Point.from_x_y(x, y)
    save
  end
end
