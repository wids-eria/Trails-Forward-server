require 'trails_forward/core_extensions'

module TrailsForward::CoreExtensions
  module Vector
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def from_rad radians
        self[Math.cos(radians), Math.sin(radians)]
      end

      def from_deg degrees
        self.from_rad(degrees * Math::PI/180)
      end

      def from_heading degrees
        self.from_deg(90 - degrees)
      end
    end

    def clean
      self.map {|x| x.round(8)}
    end

    def normalize
      return self if self.r == 0
      self / self.r
    end

    def square_r
      return 0 if self.r == 0
      1 / self.normalize.map(&:abs).max
    end

    def square_in_r? radius
      if radius == 0
        self.all? {|x| x >= -1 && x < 1}
      else
        dist = self.r - self.square_r

        if dist < radius
          true
        else
          dist == radius && self.max > self.min.abs
        end
      end
    end

    def to_rad
      Math.atan2(self[1].to_f, self[0].to_f) % (2 * Math::PI)
    end

    def to_deg
      self.to_rad * 180 / Math::PI
    end

    def to_heading
      (90 - self.to_deg) % 360
    end
  end
end
