require 'trails_forward/world_generation'
require 'trails_forward/map_maker'

class World < ActiveRecord::Base
  include TrailsForward::WorldGeneration
  include TrailsForward::MapMaker

  acts_as_api

  has_many :megatiles
  has_many :resource_tiles
  has_many :resources
  has_many :players
  has_many :listings
  has_many :change_requests
  has_many :agents
  has_many :megatile_region_caches

  validates :height, :numericality => {:greater_than => 0}
  validates :width, :numericality => {:greater_than => 0}
  validates :megatile_width, :numericality => {:greater_than => 0}
  validates :megatile_height, :numericality => {:greater_than => 0}
  validates :name, :presence => true
  validates :start_date, :presence => true
  validates :current_date, :presence => true

  validate :world_dimensions_are_consistent

  def manager
    @manager ||= GameWorldManager.for_world(self)
  end

  def yearly_tick
    grow_trees!
  end

  def tiles_in_range x, y, radius
    begin
      ResourceTile.find(tile_ids_in_range x, y, radius)
    rescue Exception => e
      require 'ruby-debug'; Debugger.start; Debugger.settings[:autoeval] = 1; Debugger.settings[:autolist] = 1; debugger 
      puts e
    end
  end

  def agents_in_range x, y, radius
    Agent.where('resource_tile_id IN (?)', tile_ids_in_range(x, y, radius)).select do |agent|
      x_offset = agent.x - x
      y_offset = agent.y - y
      x_offset * x_offset + y_offset * y_offset <= radius * radius
    end
  end

  def tile_ids_in_range x, y, radius
    x_min = [(x - radius).to_i, 0].max
    x_max = [(x + radius).to_i, width - 1].min
    y_min = [(y - radius).to_i, 0].max
    y_max = [(y + radius).to_i, height - 1].min
    x_range = (x_min..x_max)
    y_range = (y_min..y_max)
    x_range.inject([]) do |memo, test_x|
      memo << y_range.inject([]) do |memo2, test_y|
        memo2 << tile_id_at(test_x,test_y) if tile_in_range?(test_x, test_y, x, y, radius)
        memo2
      end
    end.flatten
  end

  def tile_in_range? test_x, test_y, x, y, radius
    return false if test_x < 0 || test_x >= width || test_y < 0 || test_y >= height
    return true if test_x == x.floor && test_y == y.floor

    if test_x == x.floor
      return (test_y < y && test_y + 1 > y - radius) || (test_y > y && test_y < y + radius)

    elsif test_y == y.floor
      return (test_x < x && test_x + 1 > x - radius) || (test_x > x && test_x < x + radius)

    else
      x_offset = x - (test_x < x ? test_x + 1 : test_x)
      y_offset = y - (test_y < y ? test_y + 1 : test_y)
      dist = x_offset * x_offset + y_offset * y_offset
      return dist < radius * radius
    end
  end

  def first_tile_id
    @first_tile_id ||= resource_tile_at(0,0).id
  end

  def tile_id_at x, y
    first_tile_id + (y * width) + x
  end

  def tick
    tick_agents
    age_agents!

    tick_tiles

    self.reload
    self.current_date += tick_length
  end

  def tick_length
    1.day
  end

  def tick_agents
    progeny = []
    agents.each do |agent|
      agent.reload
      progeny += agent.tick!
    end
    Agent.import progeny, validate: false, timestamps: false
  end

  def age_agents!
    Agent.age! self
  end

  def tick_tiles
  end

  def grow_trees!
    land_tiles = self.resource_tiles.where(type: 'LandTile')

    land_tiles.each do |land|
      land.grow_trees
    end
  end

  def each_resource_tile &blk
    each_coord do |x,y|
      yield resource_tile_at(x,y)
    end
  end

  def coords
    (0...width).collect do |x|
      (0...height).collect do |y|
        [x,y]
      end
    end.inject(:+)
  end

  def each_coord &blk
    coords.each do |x, y|
      yield x, y
    end
  end

  def each_megatile &blk
    each_megatile_coord do |x, y|
      yield megatile_at(x, y)
    end
  end

  def megatile_coords
    (0...width).step(megatile_width).collect do |x|
      (0...height).step(megatile_height).collect do |y|
        [x, y]
      end
    end.inject(:+)
  end

  def each_megatile_coord &blk
    megatile_coords.each do |x, y|
      yield x, y
    end
  end

  def megatile_at(x,y)
    resource_tile_at(x,y).megatile
  end

  def resource_tile_at(x,y)
    ResourceTile.where(x: x.floor, y: y.floor, world_id: id).first
  end

  def player_for_user(user)
    players.where(:user_id => user.id).first
  end

  # TODO: make scope
  def completed_change_requests
    change_requests.where(:complete => true)
  end

  # TODO: make scope
  def pending_change_requests
    change_requests.where(:complete => false)
  end

  def year_current
    current_date.year
  end

  def year_start
    start_date.year
  end

  api_accessible :world_without_tiles do |template|
    template.add :id
    template.add :name
    template.add :year_start
    template.add :year_current
    template.add :height
    template.add :width
    template.add :megatile_width
    template.add :megatile_height
    template.add :created_at
    template.add :updated_at
    template.add :players, :template => :id_and_name
    template.add :turn_started_at
    template.add :current_turn
    template.add :timber_count
  end

private

  def world_dimensions_are_consistent
    errors.add(:width, "must be a multiple of megatile_width") unless (width % megatile_width == 0)
    errors.add(:height, "must be a multiple of megatile_height") unless (height % megatile_height == 0)
  end

end
