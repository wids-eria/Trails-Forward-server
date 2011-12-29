require 'trails_forward/world_generation'
require 'trails_forward/map_maker'

class World < ActiveRecord::Base
  include TrailsForward::WorldGeneration
  include TrailsForward::MapMaker

  acts_as_api

  has_many :megatiles
  has_many :resource_tiles
  has_many :players
  has_many :listings
  has_many :change_requests
  has_many :agents

  validates :height, :numericality => {:greater_than => 0}
  validates :width, :numericality => {:greater_than => 0}
  validates :megatile_width, :numericality => {:greater_than => 0}
  validates :megatile_height, :numericality => {:greater_than => 0}
  validates :name, :presence => true

  validate :world_dimensions_are_consistent

  def manager
    @manager ||= GameWorldManager.for_world(self)
  end

  def tick
    grow_trees!
    age_agents!
    tick_agents
    tick_tiles
    self.current_date += tick_length
  end

  def tick_length
    1.day
  end

  def grow_trees!
    LandTile.grow_trees! self
  end

  def age_agents!
    Agent.age! self
  end

  def tick_agents

  end

  def tick_tiles

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
  end

private

  def world_dimensions_are_consistent
    errors.add(:width, "must be a multiple of megatile_width") unless (width % megatile_width == 0)
    errors.add(:height, "must be a multiple of megatile_height") unless (height % megatile_height == 0)
  end

end
