module LocativeDocumentInWorld
  extend ActiveSupport::Concern
  
  included do
    belongs_to :mundo, index: true

    field :_x, type: Integer
    field :_y, type: Integer
    field :location, type: Array, spacial: true

    index :_x
    index :_y
    index [[:location, Mongo::GEO2D], [:mundo_id, 1]],  {:min => 0, :max => 2000, :bits => 32} 

    validates_presence_of :mundo
    validates_presence_of :_x
    validates_presence_of :_y
    validates_presence_of :location

    #validate :fits_in_mundo?

    def location=(coords)
      if coords.respond_to? :key
        self.x = coords[:lat]
        self.y = coords[:lng]
      else
        self.x = coords[0]
        self.y = coords[1]
      end
    end

    def x
      self._x
    end

    def y
      self._y
    end

    def x=(new_x)
      set_x_y(new_x, self._y)
      self.x
    end

    def y=(new_y)
      set_x_y(self._x, new_y)
      self.y
    end
    
    def set_x_y(new_x, new_y)
      self._x = new_x
      self._y = new_y
      loc_list = [new_x, new_y]
      # self.location = {:lng => new_x, :lat => new_y}
      self[:location] = loc_list
      loc_list
    end

    #def fits_in_mundo?
    #  errors.add(:_x, "must be less than mundo width") unless (_x < mundo.width)
    #  errors.add(:_y, "must be less than mundo height") unless (_y < mundo.height)
    #end
    
    def turtles_in_radius(radius)
      Turtle.where(:mundo_id => mundo.id, :_id.ne => self.id).geo_near([x, y], :max_distance => radius)
    end
    
    def turtles_of_species_in_radius(species, radius)
      Turtle.excludes(:_id => self.id).where(:mundo_id => mundo.id, :_type => species).geo_near([x, y], :max_distance => radius)
    end
    
    def patches_in_radius(radius)
      Patch.where(:mundo_id => mundo.id, :_id.ne => self.id).geo_near([x, y], :max_distance => radius)
    end
    
  end
end
