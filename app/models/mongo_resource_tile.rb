class MongoResourceTile
  include Mongoid::Document
  include TrailsForward::MongoSpacial

  field :x,                      type: Integer
  field :y,                      type: Integer

  # field :development_intensity,  type: Float
  # field :frontage,               type: Float
  # field :housing_density,        type: Float
  # field :imperviousness,         type: Float
  # field :lakesize,               type: Float
  # field :landcover_class_code,   type: Integer
  # field :people_density,         type: Float
  # field :primary_use,            type: String
  # field :soil,                   type: Integer
  # field :tree_density,           type: Float
  # field :tree_size,              type: Float
  # field :tree_species,           type: String
  # field :zoned_use,              type: String

  belongs_to :mongo_mega_tile
  alias :mega_tile :mongo_mega_tile
  alias :mega_tile= :mongo_mega_tile=

  belongs_to :mongo_world
  alias :world :mongo_world
  alias :world= :mongo_world=
end
