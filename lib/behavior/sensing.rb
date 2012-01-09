module Behavior
  module Sensing
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
    end
  end
end
