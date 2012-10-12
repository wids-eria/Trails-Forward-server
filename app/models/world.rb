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

  validates :height, :numericality => {:greater_than => 0}
  validates :width, :numericality => {:greater_than => 0}
  validates :megatile_width, :numericality => {:greater_than => 0}
  validates :megatile_height, :numericality => {:greater_than => 0}
  validates :name, :presence => true
  validates :start_date, :presence => true
  validates :year_current, :presence => true

  validates :turn_started_at, :presence => true

  validate :world_dimensions_are_consistent

  scope :in_play, where(turn_state: 'playing')
  scope :ready_for_processing, where(turn_state: 'ready_for_processing')

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
    raise 'use the world turn manager'
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

  # FIXME: reverting back to integer for year, since database bonks out after
  # the date year 9999 in a date field
  def current_date
    start_date + (year_current - start_date.year).years
  end

  def current_date=(value)
    self.year_current = value.year
  end

  def year_start
    start_date.year
  end
  
  def migrate_population_to_most_desirable_tiles!(population)
    log = TimeStampLogger.new(File.join("log", "world_#{self.id}_turns"), 'daily')

    #zero out occupancy
    ResourceTile.connection.execute("UPDATE resource_tiles SET housing_occupants = 0 WHERE world_id=#{self.id}")
  
    #stick people in the best places first, and prefer less populated over more populated 
    places_with_people = []
  
    #Can't do the following because order is ignored by find_in_batches
    #    world.resource_tiles.most_desirable.where('housing_capacity > 0').find_in_batches do |group|
    batch_size = 10
    ((self.width * self.height)/batch_size).ceil.times do |page|
      group = self.resource_tiles.most_desirable.paginate(:page => page + 1, :per_page => batch_size).to_a
      best_places = group.sort {|x, y| x.housing_capacity <=> y.housing_capacity }
      best_places.each do |rt|
        rt.housing_occupants = [rt.housing_capacity, population].min
        population -= [rt.housing_capacity, population].min
        places_with_people << rt
        rt.save!
        break if population <= 0
      end 
      log.info "population remaining #{population}"
      break if population <= 0
    end 

    #TODO: give rent to owners of occupied land.
    puts "#{places_with_people.count} tiles are now occupied"
  end

  def update_total_desirability_scores!
    resource_tiles.each do |tile|
      tile.update_total_desirability_score!
    end
  end

  def human_population
    resource_tiles.sum(:housing_occupants)
  end

  def livable_tiles_count
    resource_tiles.where('housing_capacity > 0').count
  end

  def update_marten_suitability
    self.resource_tiles.land_tiles.each do |tile| 
      tile.calculate_marten_suitability true
      tile.save
    end
  end
  
  def update_marten_suitability_and_count_of_suitable_tiles
    update_marten_suitability
  end
  
  def marten_suitable_tile_count
    self.resource_tiles.marten_suitable.count
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
    template.add :marten_suitable_tile_count
    template.add :human_population
    template.add :livable_tiles_count
  end

  def pine_sawtimber_price
    Pricing.new(self).pine_sawtimber_price
  end

private

  def world_dimensions_are_consistent
    errors.add(:width, "must be a multiple of megatile_width") unless (width % megatile_width == 0)
    errors.add(:height, "must be a multiple of megatile_height") unless (height % megatile_height == 0)
  end

end
