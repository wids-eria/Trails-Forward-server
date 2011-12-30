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

  # has_many :players
  # has_many :listings
  # has_many :change_requests
  # has_many :agents
end
