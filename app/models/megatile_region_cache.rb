class MegatileRegionCache <  ActiveRecord::Base
  belongs_to :world
  has_many :megatiles

  validates_uniqueness_of :y_max, :scope => [:world_id, :y_min, :x_min, :x_max]
  validates_uniqueness_of :y_min, :scope => [:world_id, :y_max, :x_min, :x_max]
  validates_uniqueness_of :x_min, :scope => [:world_id, :y_min, :y_max, :x_max]
  validates_uniqueness_of :x_max, :scope => [:world_id, :y_min, :x_min, :y_max]

  scope :in_region, lambda { |world_id, coordinates|
    exclusion_box = "NOT (x_max < :x_min OR x_min > :x_max OR y_max < :y_min OR y_min > :y_max)"
    where(world_id: world_id).where(exclusion_box, coordinates)
  }

  def self.combine_json(jsonlist)
    ret = "["
    list_length = jsonlist.count
    list_length.times do |i|
      ret << jsonlist[i]
      ret << "," if (i < (list_length - 1))
    end
    ret << "]"
  end

  def self.megatiles_in_region(world_id, coordinates) 
    coordinates.reverse_merge! x_min: 0, x_max: 0, y_min: 0, y_max: 0

    caches = MegatileRegionCache.in_region(world_id, coordinates)
    jsonlist = caches.map { |cache| cache.json.strip[1..-2] }  #this should be one long list; we don't want the square brackets

    json = MegatileRegionCache.combine_json jsonlist
    last_modified = Megatile.where(megatile_region_cache_id: caches.map(&:id)).maximum(:updated_at)
    {last_modified: last_modified, json: json}
  end


  def json
    Rails.cache.fetch(cache_key) do
      jsonlist = self.megatiles.map { |mt| mt.json }
      MegatileRegionCache.combine_json jsonlist
    end
  end

  def invalidate
    Rails.cache.delete cache_key
  end

  def cache_key
    "MegatileRegionCache #{self.id}"
  end

end
