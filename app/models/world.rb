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

  def manager
    @manager ||= GameWorldManager.for_world(self)
  end

  def each_resource_tile &blk
    each_coord do |x,y|
      yield resource_tile_at(x,y)
    end
  end

  def each_coord &blk
    (0...width).each do |x|
      (0...height).each do |y|
        yield x, y
      end
    end
  end

  def each_megatile &blk
    each_megatile_coord do |x, y|
      yield megatile_at(x, y)
    end
  end

  def each_megatile_coord &blk
    (0...width).step(megatile_width) do |x|
      (0...height).step(megatile_height) do |y|
        yield x, y
      end
    end
  end

  # TODO: make scope
  def megatile_at(x,y)
    resource_tile_at(x,y).megatile
  end

  # TODO: make scope
  def resource_tile_at(x,y)
    ResourceTile.where(x: x, y: y, world_id: id).first
  end

  # TODO: make scope
  def player_for_user(user)
    players.where(:user_id => user.id).first
  end

  # TODO: make scope
  def completed_change_requests
    change_requests.where(:complete => true)
  end

  # TODO: make scope
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

  def spawn_tiles
    raise "Can't spawn tiles for an invalid World" unless valid?
    each_megatile_coord do |x,y|
      mt = Megatile.create(:x => x, :y => y, :world => self)
      mt.spawn_resources
    end
    self
  end

  def place_resources
    how_many_trees = (width * height * 0.40).round

    each_resource_tile do |resource_tile|
      resource_tile.type = 'LandTile'
      case rand 9
      when 0
        resource_tile.clear_resources
        resource_tile.type = 'WaterTile'
      when 1..6
        resource_tile.primary_use = nil
        resource_tile.people_density = 0
        resource_tile.housing_density = resource_tile.people_density
        resource_tile.tree_density = 0.5 + rand()/2.0
        resource_tile.tree_species = "Deciduous"
        resource_tile.development_intensity = 0.0
        resource_tile.zoned_use = "Logging" if (rand(10) == 0)
      when 7..8
        resource_tile.primary_use = "Residential"
        resource_tile.zoned_use = "Development"
        resource_tile.people_density = 0.5 + rand()/2.0
        resource_tile.housing_density = resource_tile.people_density
        resource_tile.tree_density = rand() * 0.1
        resource_tile.tree_species = nil
        resource_tile.development_intensity = resource_tile.housing_density
      end
      resource_tile.save
    end
    self
  end

  def create_users_and_players
    player_types = [Lumberjack, Developer, Conserver]
    player_types.each_with_index do |player_type, idx|
      password = "letmein"
      email = "u#{id}-#{idx+1}@example.com"

      user = User.create!(email: email,
                          password: password,
                          name: "User #{id}-#{idx+1}")

      player_type.create!(user: user,
                          world: self,
                          balance: Player::DefaultBalance)
    end
    self
  end

  def create_starter_properties
    ((width / 6) * (height / 6)).times do
      x = rand width
      y = rand height
      megatile = megatile_at x,y
      megatile.update_attributes(owner: players[rand(players.count)])
    end
    self
  end

private

  def world_dimensions_are_consistent
    errors.add(:width, "must be a multiple of megatile_width") unless (width % megatile_width == 0)
    errors.add(:height, "must be a multiple of megatile_height") unless (height % megatile_height == 0)
  end

end
