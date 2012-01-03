class Agent < ActiveRecord::Base
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

  def nearby_stuff opts = {}
    opts = {}.merge opts
    opts[:radius] = [opts[:radius], max_view_distance].compact.min

    local_search = opts[:class].where(world_id: world_id).in_square_range(opts[:radius], self.x, self.y)
    local_search = local_search.for_types(opts[:types]) if opts[:types]
    local_search
  end

  def nearby_tiles opts = {}
    opts[:radius] = [opts[:radius], max_view_distance].compact.min
    nearby_stuff opts.merge(class: ResourceTile)
  end

  def nearby_agents opts = {}
    opts[:radius] = [opts[:radius], max_view_distance].compact.min
    nearby_stuff(opts.merge class: Agent).reject do |a|
      vect = (Vector[*a.location] - Vector[*self.location])
      vect.magnitude > opts[:radius] || a == self
    end
  end

  def nearby_peers opts = {}
    opts[:radius] = [opts[:radius], max_view_distance].compact.min
    nearby_agents opts.merge({types: [self.class]})
  end

  def location= coords
    self.x = coords[0]
    self.y = coords[1]
    self.resource_tile = world.resource_tile_at(self.x.floor, self.y.floor)
  end

  def location
    [x, y]
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

  # def move distance, set_resource_tile = true
  #   pos = position_after_move distance
  #   self.heading = pos[:heading]
  #   if set_resource_tile
  #     self.location = pos[:location]
  #   else
  #     self.x = pos[:location][0]
  #     self.y = pos[:location][1]
  #   end
  # end

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
    progeny = tick || []
    save! if changed?
    self.class.import progeny, validate: false, timestamps: false
  end

  def tick
    die! and return if should_die?
    go
  end

  def die!
    self.destroy
  end

  def should_die?
    false
  end

  def litter_size
    1
  end

  def reproduce
    litter = litter_size.times.map do
      new_descendant
    end
  end

  def new_descendant
    self.class.new(world: world,
                   resource_tile: resource_tile,
                   heading: rand(360).round,
                   x: self.x,
                   y: self.y)
  end

  def go
    raise NotImplementedError
  end

private

  def setup_resource_tile
    return unless x && y && world
    self.resource_tile ||= world.resource_tile_at(x, y)
  end
end
