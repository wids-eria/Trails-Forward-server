class MongoAgent
  include Mongoid::Document

  field :x,        type: Float
  field :y,        type: Float
  field :heading,  type: Integer
  field :state,    type: String
  field :age,      type: Integer

  belongs_to :mongo_world
  alias :world, :mongo_world
  alias :world=, :mongo_world=
end
