class World < ActiveRecord::Base
  acts_as_api

  has_many :megatiles
  has_many :resource_tiles
  has_many :players
  has_many :listings
  has_many :change_requests

  validates :height, :numericality => {:greater_than => 0}
  validates :width, :numericality => {:greater_than => 0}
  validates :megatile_width, :numericality => {:greater_than => 0}
  validates :megatile_height, :numericality => {:greater_than => 0}
  validates :name, :presence => true

  validate :world_dimensions_are_consistent

  def world_dimensions_are_consistent
    errors.add(:width, "must be a multiple of megatile_width") unless (width % megatile_width == 0)
    errors.add(:height, "must be a multiple of megatile_height") unless (height % megatile_height == 0)
  end


  def spawn_tiles(display_progress = false)
    raise "Can't spawn tiles for an invalid World" unless valid?
    each_megatile_coord do |x,y|
      mt = Megatile.create(:x => x, :y => y, :world => self)
      mt.spawn_resources
      if display_progress
        print "."
        STDOUT.flush
      end
    end
    if display_progress
      puts ""
    end
  end

  def each_coord &blk
    (0...width).each do |x|
      (0...height).each do |y|
        yield x, y
      end
    end
  end

  def each_megatile_coord &blk
    (0...width).step(megatile_width) do |x|
      (0...height).step(megatile_height) do |y|
        yield x, y
      end
    end
  end

  def each_resource_tile &blk
    each_coord do |x,y|
      yield resource_tile_at(x,y)
    end
  end

  def each_megatile &blk
    each_megatile_coord do |x, y|
      yield megatile_at(x, y)
    end
  end

  def megatile_at(x,y)
    resource_tile_at(x,y).megatile
  end

  def resource_tile_at(x,y)
    ResourceTile.where(x: x, y: y, world_id: id).first
  end

  def manager
    @manager ||= GameWorldManager.for_world(self)
  end

  def player_for_user(user)
    players.where(:user_id => user.id).first
  end

  def completed_change_requests
    change_requests.where(:complete => true)
  end

  def pending_change_requests
    change_requests.where(:complete => false)
  end

  api_accessible :world_without_tiles do |template|
    template.add :id
    template.add :name
    template.add :year_start
    template.add :year_current
    template.add :height
    template.add :width
    template.add :megatile_width
    template.add :megatile_height
    template.add :created_at
    template.add :updated_at
    template.add :players, :template => :id_and_name
  end

end
