class Tortuga
  include Mongoid::Document
  include Mongoid::Spacial::Document
  include LocativeDocumentInWorld
  
  field :heading, type: Float, default: 0
  field :age, type: Integer, default: 0
  
  before_save :wrap_heading
  belongs_to :patch
  
  def wrap_heading
    self.heading = self.heading % 360
  end
  
  def forward(distance)
    self.x += distance * Math::cos( Turtle.degrees_to_radians self.heading )
    self.y += distance * Math::sin( Turtle.degrees_to_radians self.heading )
    
    self.x = self.x % self.mundo.width
    self.y = self.y % self.mundo.height
  end


  scope :for_types, lambda { |types| any_in(_type: types.map{|t| t.to_s.classify}) }
  scope :for_type, lambda { |type| where(_type: type.to_s.classify) }

  def turn(degrees)
  end
  
  def turn_right(degrees)
    self.heading -= degrees
  end
  
  def turn_left(degrees)
    turn_right(0-degrees)
  end
  
  def do_tick
    tick
    save!
  end

  def tick
    self.age += 1
    die! and return if should_die?

    go
  end

  def die!
    self.destroy
  end

  def should_die?
    false
  end
  
  def self.degrees_to_radians(degrees)
    (degrees/180.0)*Math::PI
  end

  def nearby_tiles

  end

  def nearby_peers
  end
end
