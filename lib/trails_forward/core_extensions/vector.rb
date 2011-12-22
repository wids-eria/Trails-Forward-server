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
        self.from_radians(degrees * Math::PI/180)
      end

      def from_heading degrees
        self.from_degrees(90 - degrees)
      end

      def sum *vectors
        vectors.flatten! if vectors.respond_to? :flatten
        vectors.inject(:+)
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
        self.all? {|x| x >= -1 && x < 1}
      else
        dist = self.magnitude - self.square_r

        if dist < radius
          true
        else
          dist == radius && self.max > self.min.abs
        end
      end
    end

    def to_radians
      Math.atan2(self[1].to_f, self[0].to_f) % (2 * Math::PI)
    end

    def to_degrees
      self.to_radians * 180 / Math::PI
    end

    def to_heading
      (90 - self.to_degrees) % 360
    end

    def radians_to other
      Math.acos(self.projection_onto other)
    end

    def degrees_to other
      self.radians_to(other) * 180 / Math::PI
    end

    def projection_onto other
      self.normalize.inner_product(other.normalize)
    end

    def projection_from *vects
      self.class.sum(*vects).projection_onto self
    end
  end
end
