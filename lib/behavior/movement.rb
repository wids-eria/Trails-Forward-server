module Behavior
  module Movement
    def move?
      false
    end

    def move
    end

    def turn degrees
      self.heading += degrees
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
          require 'ruby-debug'; Debugger.start; Debugger.settings[:autoeval] = 1; Debugger.settings[:autolist] = 1; debugger unless self.resource_tile
        end
      end
    end
  end
end
