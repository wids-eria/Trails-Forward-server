class World < ActiveRecord::Base
  versioned
  
  acts_as_api
  
  has_many :megatiles
  has_many :resource_tiles
  has_many :players
  has_many :listings
  
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
    if valid?
      Range.new(0,width-1).step(megatile_width) do |x|
        Range.new(0,height-1).step(megatile_height) do |y|
          mt = Megatile.new(:x => x, :y => y, :world => self)
          mt.save
          mt.spawn_resources
          if display_progress
            print "."
            STDOUT.flush
          end
        end
      end 
      if display_progress
        puts ""
      end     
    else
      raise "Can't spawn tiles for an invalid World"
    end
  end

  def megatile_at(x,y)
    resource_tile_at(x,y).megatile
  end
  
  def resource_tile_at(x,y)
    ResourceTile.where(:world_id => self.id).where(:x => x).where(:y => y).limit(1)[0]
  end
  
  def manager
    GameWorldManager.for_world(self)
  end
  
  def player_for_user(user)
    players.where(:user_id => user.id).first
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
