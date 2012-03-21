class MegatileRegionCache <  ActiveRecord::Base
  belongs_to :world
  has_many :megatiles
  
  validates_uniqueness_of :y_max, :scope => [:world_id]
  validates_uniqueness_of :y_min, :scope => [:world_id]
  validates_uniqueness_of :x_min, :scope => [:world_id]
  validates_uniqueness_of :x_max, :scope => [:world_id]
  
  def self.CombineJSONs(jsonlist)
    ret = "["
    list_length = jsonlist.count
    list_length.times do |i|
      ret << jsonlist[i]
      ret << ", " if (i < (list_length - 1))
    end
    ret << "]"
  end
  
  def self.MegatilesInRegion(world_id, x_min, y_min, x_max, y_max)
    caches = MegatileRegionCache.where(:world_id => world_id).where("x_min >= :x_min AND x_max<= :x_max AND y_min >= :y_min AND y_max <= :y_max",
                                                              {:x_min => x_min, :x_max => x_max, :y_min => y_min, :y_max => y_max})
    jsonlist = caches.map { |cache| cache.json.strip[1..-2] }  #this should be one long list; we don't want the square brackets
    
    CombineJSONs jsonlist
  end
  
  def json
    Rails.cache.fetch(cache_key) do
      jsonlist = self.megatiles.map { |mt| mt.json }
      CombineJSONs jsonlist
    end
  end
  
  def invalidate
    Rails.cache.delete cache_key
  end
  
  def cache_key
    "MegatileRegionCache #{self.id}"
  end
  
end