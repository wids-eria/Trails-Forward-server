require 'singleton'

class GameWorldManager
  attr_reader :world
  attr_reader :the_state
  attr_reader :broker

  def self.for_world(world)
    #see end of this file
    GameWorldManagerFactory.instance.manager_for_world(world)
  end

  def self.for_world_id(world_id)
    GameWorldManagerFactory.instance.manager_for_world_id(world_id)
  end

  def initialize(world)
    @world = world
    @the_state = TheState.new world
    @broker = Broker.new world
  end

  def tick_critters
    critter_ticker = CritterTicker.new @world
    critter_ticker.tick_all
  end

  def tick_trees
    TreeTicker.tick @world
  end

  def execute_trades
    TradeTicker.tick @world
  end

  def execute_builds
    BuildTicker.tick @world
  end

  def collect_rent

  end

  def tick_world(times = 1)
    ActiveRecord::Base.transaction do
      #@world.lock!
      times.times do
        execute_trades
        execute_builds
        tick_trees
        tick_critters
        collect_rent
        @world.year_current += 1
        @world.save!
      end
    end #transaction
  end

end

class GameWorldManagerFactory
  include Singleton

  def initialize
    @managers = {}
  end

  def manager_for_world(world)
    if not (@managers.has_key? world)
      @managers[world] = GameWorldManager.new(world)
      @managers[world.id] = @managers[world]
    end

    @managers[world.id]
  end

  def manager_for_world_id(world_id)
    if @managers.has_key? world_id
      return @managers[world_id]
    else
      world = World.find(world_id)
      return manager_for_world(world)
    end
  end
end
