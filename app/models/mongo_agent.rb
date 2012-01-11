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
    eat
    move
    reproduce
    die
  end



  ### BASE BEHAVIOR ######################

  def die
    puts "die"
  end

  def reproduce
    puts "reproduce"
  end

  def move
    puts "move"
  end

  def eat
    puts "eat"
  end



  ### HELPERS ############################

  def nearby_agents

  end

  def nearby_tiles

  end
end
