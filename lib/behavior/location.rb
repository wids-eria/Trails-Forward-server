module Behavior
  module Location
    def location= coords
      #begin
        #puts "LOC: #{x} #{y}"
        self.x, self.y = coords
        self.resource_tile = world.resource_tile_at(self.x.floor, self.y.floor)
      #rescue Exception => e
      #  puts "IN LOCATION"
      #  debugger
      #end
    end

    def location
      [x, y]
    end

    def vector_to other
      Vector[other.x - self.x, other.y - self.y]
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
    end
  end
end
