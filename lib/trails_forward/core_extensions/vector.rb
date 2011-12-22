require 'trails_forward/core_extensions'

module TrailsForward::CoreExtensions
  module Vector
    def self.included(base)
      base.extend ClassMethods
      base.send :alias_method, :magnitude, :r
    end

    module ClassMethods
      def from_radians radians
        self[Math.cos(radians), Math.sin(radians)]
      end

      def from_degrees degrees
        self.from_radians(deg2rad degrees)
      end

      def from_heading degrees
        self.from_degrees(90 - degrees)
      end

      def sum *vectors
        vectors.flatten.inject(:+)
      end

      def deg2rad deg
        deg * Math::PI / 180
      end

      def rad2deg rad
        rad * 180 / Math::PI
      end
    end

    def clean
      self.map {|x| x.round(8)}
    end

    def decompose
      components = []
      self.each_with_index do |x, idx|
        tuple = Array.new(self.size) { 0 }
        tuple[idx] = x
        components << self.class[*tuple]
      end
      components
    end

    def normalize
      return self if self.magnitude == 0
      self / self.magnitude
    end

    def square_r
      return 0 if self.magnitude == 0
      1 / self.normalize.map(&:abs).max
    end

    def square_in_r? radius
      if radius == 0
        self.all? {|x| (-1...1).include? x }
      else
        dist = self.magnitude - self.square_r

        if dist < radius
          true
        else
          dist == radius && self.max > self.min.abs
        end
      end
    end

    def with_magnitude val
      self * (val / self.magnitude.to_f)
    end

    def to_radians
      Math.atan2(self[1].to_f, self[0].to_f) % (2 * Math::PI)
    end

    def to_degrees
      rad2deg(self.to_radians)
    end

    def to_heading
      (90 - self.to_degrees) % 360
    end

    def rotate_by_radians radians
      x_component = (self[0] * Math.cos(radians)) - (self[1] * Math.sin(radians))
      y_component = (self[0] * Math.sin(radians)) + (self[1] * Math.cos(radians))
      self.class[x_component, y_component]
    end

    def rotate_by_degrees degrees
      self.rotate_by_radians deg2rad(degrees)
    end

    def rotate_by_heading degrees
      self.rotate_by_degrees(-degrees)
    end

    def rotate_to_radians radians
      self.class.from_radians(radians) * self.magnitude
    end

    def rotate_to_degrees degrees
      self.rotate_to_radians(deg2rad degrees)
    end

    def rotate_to_heading degrees
      self.rotate_to_degrees 90 - degrees
    end

    def abs_radians_to other
      Math.acos(self.normalize.inner_product other.normalize)
    end

    def radians_to other
      result = self.abs_radians_to other
      clockwise = self.rotate_by_radians(Math::PI / 2).abs_radians_to(other) > Math::PI / 2
      result *= -1 if clockwise
      result
    end

    def degrees_to other
      rad2deg self.radians_to(other)
    end

    def heading_to other
      -self.degrees_to(other)
    end

    def projected_magnitude *others
      others.flatten.map do |other|
        self.normalize.inner_product(other.normalize) * self.magnitude
      end.inject(:+)
    end

    def projection_onto other
      other.with_magnitude(projected_magnitude other)
    end

    def projection_from *vects
      self.class.sum(*vects).projection_onto self
    end

  protected

    def deg2rad deg
      self.class.deg2rad deg
    end

    def rad2deg rad
      self.class.rad2deg rad
    end
  end
end
