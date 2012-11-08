class Megatile < ActiveRecord::Base
  acts_as_api

  belongs_to :world
  belongs_to :owner, :class_name => 'Player'
  has_many :resource_tiles

  has_and_belongs_to_many :megatile_groupings
  has_many :listings, :through => :megatile_groupings
  has_many :bids_on, :through => :megatile_groupings
  has_many :bids_offering, :through => :megatile_groupings

  has_and_belongs_to_many :contracts_included_with, :join_table => 'contract_included_megatiles'
  has_and_belongs_to_many :contracts_attached_to,   :join_table => 'contract_attached_megatiles'


  has_many :surveys

  validates_presence_of :world

  validates_uniqueness_of :x, :scope => [:y, :world_id]
  validates_uniqueness_of :y, :scope => [:x, :world_id]
  
  scope :in_region, lambda { |world_id, coordinates|
    exclusion_box = "NOT (x < :x_min OR x> :x_max OR y < :y_min OR y > :y_max)"
    where(world_id: world_id).where(exclusion_box, coordinates)
  }
  

  def self.cost
    100
  end

  def width
    world.try(:megatile_width)
  end

  def height
    world.try(:megatile_height)
  end

  def active_listings
    listings.where(status: 'Active')
  end

  def active_bids_on
    bids_on.where(status: 'Offered')
  end

  def active_bids_offering
    bids_offering.where(status: 'Offered')
  end


  def estimated_value
    total_price = 0
    resource_tiles.each do |rt|
      tmp_price = rt.estimated_value
      if tmp_price != nil
        total_price += tmp_price
      end
    end
    total_price
  end

  api_accessible :id_and_name do |template|
    template.add :id
    template.add :x
    template.add :y
    template.add :updated_at
  end

  api_accessible :megatile_with_owner, :extend => :id_and_name do |template|
    template.add :owner, :template => :id_and_name
  end

  api_accessible :megatile_with_resources, :extend => :megatile_with_owner do |template|
    template.add :resource_tiles, :template => :resource
  end

  api_accessible :megatiles_with_resources, :extend => :megatile_with_resources

  api_accessible :megatile_with_value, :extend => :id_and_name do |template|
    template.add :estimated_value
  end

  api_accessible :megatiles_with_value, :extend => :megatile_with_value
  
  def json
    Rails.cache.fetch(cache_key) do
      MegatilePresenter.new(self).as_json
    end
  end
  
  def invalidate_cache
    Rails.cache.delete cache_key
  end
  
  def cache_key
    "megatile_with_resources #{self.id}"
  end

end
