module Behavior
  module Movement
    def move?
      false
    end

    def walk_forward distance
      offset = self.class.calculate_offset_coordinates self.heading, distance    
      location = [self.x + offset[0], self.y + offset[1]]
      #self.x += offset[0]
      #self.y += offset[1]
    end

    def turn degrees
      self.heading += degrees
      self.heading %= 360
    end

    def position_after_move distance
      offset_coordinates = Agent.calculate_offset_coordinates(self.heading, distance)
      new_x = (self.x + offset_coordinates[0]).round(2)
      new_y = (self.y + offset_coordinates[1]).round(2)
      new_heading = self.heading

      if new_x < 0 || new_x >= world.width
        if new_x < 0
          new_x = 0
        else
          new_x = world.width - 1
        end
        new_heading = (360 - self.heading)
      end

      if new_y < 0 || new_y >= world.height
        if new_y < 0
          new_y = 0
        else
          new_y = world.height - 1
        end
        new_heading = (180 - self.heading)
      end

      {location: [new_x, new_y], heading: new_heading}
    end


    def face tile
      from_location = location
      to_location = [tile.x, tile.y]
      self.heading = ((Math.atan2(to_location[1] - from_location[1], to_location[0] - from_location[0]) * (180/Math::PI)) + 90) % 360
    end


    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def calculate_offset_coordinates heading, distance
        heading_in_radians = heading * (Math::PI / 180.0)
        x_offset = (distance * Math.sin(heading_in_radians)).round(2)
        y_offset = (distance * Math.cos(heading_in_radians)).round(2)
        [x_offset, y_offset]
      end

      def move_when &blk
        define_method :move? do
          blk.call self
        end
      end

      def move_to &blk
        define_method :move do
          self.location = blk.call(self)
        end
      end
    end
  end
end
