class MongoAgent
  include Mongoid::Document

  field :x,        type: Float
  field :y,        type: Float
  field :heading,  type: Integer
  # field :state,    type: String
  field :age,      type: Integer

  belongs_to :mongo_world
  alias :world :mongo_world
  alias :world= :mongo_world=


  def self.tick(agents)
    agents.each do |agent|
      agent.tick
    end
  end

  def tick
    die
    reproduce
    move
    eat
  end

  def die

  end

  def reproduce

  end

  def move

  end

  def eat

  end
end
