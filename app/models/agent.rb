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

  def self.age! world
    world.agents.update_all('age = age + 1')
  end

  def tick!
    save! if tick && changed?
    @litter
  end

  def tick
    @litter = []
    move if move?
    reproduce if reproduce?
    die and return if die?
    true
  end

private

  def setup_resource_tile
    return unless x && y && world
    self.resource_tile ||= world.resource_tile_at(x, y)
  end
end
