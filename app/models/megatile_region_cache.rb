class MegatileRegionCache <  ActiveRecord::Base
  belongs_to :world
  has_many :megatiles
  
  validates_uniqueness_of :y_max, :scope => [:world_id]
  validates_uniqueness_of :y_min, :scope => [:world_id]
  validates_uniqueness_of :x_min, :scope => [:world_id]
  validates_uniqueness_of :x_max, :scope => [:world_id]
  
  def Combine_jsons(jsonlist)
    ret = "["
    list_length = jsonlist.count
    list_length.times do |i|
      ret << jsonlist[i]
      ret << ", " if (i < (list_length - 1))
    end
    ret << "]"
  end
  
  def json
    Rails.cache.fetch(cache_key) do
      jsonlist = self.megatiles.map { |mt| mt.json }
      Combine_jsons jsonlist
    end
  end
  
  def invalidate
    Rails.cache.delete cache_key
  end
  
  def cache_key
    "MegatileRegionCache #{self.id}"
  end
  
end