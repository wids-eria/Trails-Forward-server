class MongoMegaTile
  include Mongoid::Document

  belongs_to :mongo_world
  alias :world :mongo_world
  alias :world= :mongo_world=

  has_many :mongo_resource_tiles
  alias :resource_tiles :mongo_resource_tiles
  alias :resource_tiles= :mongo_resource_tiles=
end
