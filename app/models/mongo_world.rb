class MongoWorld
  include Mongoid::Document

  field :name,             type: String
  field :height,           type: Integer
  field :width,            type: Integer
  field :megatile_height,  type: Integer
  field :megatile_width,   type: Integer
  field :start_date,       type: Date
  field :current_date,     type: Date

  has_many :mongo_resource_tiles
  alias :resource_tiles :mongo_resource_tiles
  alias :resource_tiles= :mongo_resource_tiles=

  has_many :mongo_agents
  alias :agents :mongo_agents
  alias :agents= :mongo_agents=

  has_many :mongo_mega_tiles
  alias :mega_tiles :mongo_mega_tiles
  alias :mega_tiles= :mongo_mega_tiles=

  # has_many :players
  # has_many :listings
  # has_many :change_requests
  # has_many :agents

  def tick
    grow_trees  # noop
    agen_agents # noop

    tick_agents 
  end

  def tick_agents
    MongoAgent.tick(agents)
  end


  ### HELPERS ############################

  def contains_coordinate?(x,y)
    x < self.width && y < self.height && x > 0 && y > 0
  end
end
