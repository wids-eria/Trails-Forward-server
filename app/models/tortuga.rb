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

  def reproduce
    litter_size.times do
      create_descendant
    end
  end

  def create_descendant
    self.class.create(mundo: mundo_id,
                      patch: patch_id,
                      heading: rand(360).round,
                      location: self.location)
  end

  def move distance
    offset_coordinates = Agent.calculate_offset_coordinates(self.heading, distance)
    new_x = (self.x + offset_coordinates[0]).round(2)
    new_y = (self.y + offset_coordinates[1]).round(2)

    if new_x < 0 || new_x >= mundo.width
      if new_x < 0
        new_x = 0
      else
        new_x = mundo.width - 1
      end
      self.heading = (360 - self.heading)
    end

    if new_y < 0 || new_y >= mundo.height
      if new_y < 0
        new_y = 0
      else
        new_y = mundo.height - 1
      end
      self.heading = (180 - self.heading)
    end

    self.location = [new_x, new_y]
  end

  def self.calculate_offset_coordinates heading, distance
    heading_in_radians = heading * (Math::PI / 180.0)
    x_offset = (distance * Math.sin(heading_in_radians)).round(2)
    y_offset = (distance * Math.cos(heading_in_radians)).round(2)
    [x_offset, y_offset]
  end

  def set_x_y(new_x, new_y)
    self._x = new_x
    self._y = new_y
    loc_list = [new_x, new_y]
    self[:location] = loc_list
    if x && y
      self.patch = Patch.where(_x: x.floor, _y: y.floor, mundo_id: mundo_id).first
    end

    loc_list
  end

  def nearby_agents opts = {}
    []
  end
end
