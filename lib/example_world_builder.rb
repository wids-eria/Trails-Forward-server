class ExampleWorldBuilder
  def self.build_example_world(args = {})
    world = Factory :world, args

    world.spawn_tiles

    self.place_resources(world)
    self.create_users_and_players(world)
    self.create_starter_property(world)

    return world
  end

  private
  def self.place_resources(world)

    how_many_trees = (world.width * world.height * 0.40).round

    world.width.times do |x|
      world.height.times do |y|
        resource_tile = world.resource_tile_at x,y
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
    end
  end

  def self.create_users_and_players(world)
    players = []
    player_types = [Lumberjack, Developer, Conserver]
    3.times do |i|
      password = "letmein"
      email = "u#{world.id}-#{i}@example.com"
      u = User.new(:email => email, :password => password, :password_confirmation => password)
      u.name = "User #{world.id}-#{i}"
      u.save!
      p = player_types[i].new do |p|
        p.user = u
        p.world = world
        p.balance = Player::DefaultBalance
      end
      p.save!
      # p.type = player_types[i]
      #   p.save
      players << p
    end
  end

  def self.create_starter_property(world)
    ((world.width / 6) * (world.height / 6)).times do
      x = rand world.width
      y = rand world.height
      megatile = world.megatile_at x,y
      megatile.owner = world.players[rand(world.players.count)]
      megatile.save
    end
  end
end
