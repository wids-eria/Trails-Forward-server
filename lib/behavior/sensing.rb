module Behavior
  module Sensing
    def max_view_distance
      0
    end

    def tile_utility tile
      0.5
    end

    def patch_ahead distance = 1
      offset = self.class.calculate_offset_coordinates self.heading, distance
      px = self.x + offset[0]
      py = self.y + offset[1]
      self.world.resource_tile_at px, py
    end

    def best_nearby_tile
      tile_utilities = nearby_tiles.map {|t| [tile_utility(t), t]}.sort
      best_utility = tile_utilities.map(&:first).max
      tile_utilities.reject {|utility, tile| utility < best_utility}.sample[1]
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
      world.tiles_in_range self.x, self.y, opts[:radius]
      # nearby_stuff opts.merge(class: ResourceTile)
    end

    def nearby_agents opts = {}
      opts[:radius] = [opts[:radius], max_view_distance].compact.min
      opts[:types] ||= []
      opts[:types] = opts[:types].map(&:to_s).map(&:classify)

      agents = world.agents_in_range(self.x, self.y, opts[:radius]) - [self]
      if opts[:types].any?
        agents.select {|a| opts[:types].include? a.type}
      else
        agents
      end
      # nearby_stuff(opts.merge class: Agent).reject do |a|
      #   vect = (Vector[*a.location] - Vector[*self.location])
      #   vect.magnitude > opts[:radius] || a == self
      # end
    end

    def nearby_peers opts = {}
      # opts[:radius] = [opts[:radius], max_view_distance].compact.min
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
