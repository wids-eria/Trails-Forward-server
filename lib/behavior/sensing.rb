module Behavior
  module Sensing
    def max_view_distance
      0
    end

    def tile_utility tile
      0.5
    end

    def best_nearby_tile
      nearby_tiles.sort {|a, b| tile_utility(b) <=> tile_utility(a)}.first
    end

    def nearby_stuff opts = {}
      opts = {}.merge opts
      opts[:radius] = [opts[:radius], max_view_distance].compact.min

      local_search = opts[:class].where(world_id: world_id).in_square_range(opts[:radius], self.x, self.y)
      local_search = local_search.for_types(opts[:types]) if opts[:types]
      local_search
    end

    def nearby_tiles opts = {}
      opts[:radius] = [opts[:radius], max_view_distance].compact.min
      nearby_stuff opts.merge(class: ResourceTile)
    end

    def nearby_agents opts = {}
      opts[:radius] = [opts[:radius], max_view_distance].compact.min
      nearby_stuff(opts.merge class: Agent).reject do |a|
        vect = (Vector[*a.location] - Vector[*self.location])
        vect.magnitude > opts[:radius] || a == self
      end
    end

    def nearby_peers opts = {}
      opts[:radius] = [opts[:radius], max_view_distance].compact.min
      nearby_agents opts.merge({types: [self.class]})
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def max_view_distance val
        define_method :max_view_distance do
          val
        end
      end

      def tile_utility &blk
        define_method :tile_utility do |tile|
          blk.call(self, tile)
        end
      end
    end
  end
end
