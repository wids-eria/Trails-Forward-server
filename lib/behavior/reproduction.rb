module Behavior
  module Reproduction
    def reproduce?
      self.age % 365 == 364
    end

    def reproduce
      @litter = litter_size.times.map do
        new_descendant
      end
    end

    def fecundity
      0
    end

    def litter_size
      result = fecundity.floor
      result += 1 if rand < (fecundity % 1.0)
      result
    end

    def new_descendant
      self.class.new(world_id: world.id,
                     resource_tile_id: resource_tile_id,
                     heading: rand(360).round,
                     x: x, y: y)
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def fecundity val
        define_method :fecundity do
          val
        end
      end
    end
  end
end
