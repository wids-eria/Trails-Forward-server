class MongoAgent
  include Mongoid::Document
  include Mongoid::Spacial::Document

  field :x,        type: Float
  field :y,        type: Float
  field :heading,  type: Integer
  # field :state,    type: String
  field :age,      type: Integer

  field :location, type: Array, spacial: true
  spacial_index :location
  before_save :set_location


  belongs_to :mongo_world
  alias :world :mongo_world
  alias :world= :mongo_world=


  def self.tick(agents)
    agents.each do |agent|
      agent.tick
      agent.save
      $bar.inc
    end
  end

  def tick
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
    nearby_agents
    nearby_tiles

    self.x += rand
    self.y += rand
  end

  def eat
  end



  ### HELPERS ############################

  def set_location
    self.location = [x,y]
  end

  def view_distance
    5
  end

  def nearby_agents
    MongoAgent.where(:mongo_world_id => world.id, :_id.ne => self.id).geo_near([x, y], :max_distance => view_distance).all
  end

  def nearby_tiles
    MongoResourceTile.where(:mongo_world_id => world.id).geo_near([x, y], :max_distance => view_distance).all
  end
end
