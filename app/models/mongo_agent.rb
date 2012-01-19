class MongoAgent
  include Mongoid::Document
  include TrailsForward::MongoSpacial

  field :x,        type: Float
  field :y,        type: Float
  field :heading,  type: Integer
  # field :state,    type: String
  field :age,      type: Integer

  belongs_to :mongo_world, index: true
  alias :world :mongo_world
  alias :world= :mongo_world=

  def self.tick(agents)
    agents.each do |agent|
      Stalker.enqueue('mongo_agent.tick', :agent_id => agent.id)
      #agent.tick
      #agent.save
      #$bar.inc
    end
  end

  def tick
    puts "."
    mature
    eat
    move
    reproduce
    die
  end



  ### BASE BEHAVIOR ######################

  def mature
    self.age ||= 1
    self.age += 1
  end

  def die
  end

  def reproduce
  end

  def move
    nearby_agents + []
    nearby_tiles + []

    self.x += rand
    self.y += rand
  end

  def eat
  end



  ### HELPERS ############################


  def view_distance
    5
  end

  def nearby_agents
    MongoAgent.where(:mongo_world_id => world.id, :_id.ne => self.id).geo_near([x, y], :max_distance => view_distance)
  end

  def nearby_tiles
    MongoResourceTile.where(:mongo_world_id => world.id).geo_near([x, y], :max_distance => view_distance)
  end
end
