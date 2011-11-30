
class ExampleWorldBuilder
  def self.build_example_world(width, height, debug=false)
    world = World.create do |w|
      w.name = "Example World #{rand(100000)}"
      w.year_start = 1880
      w.year_current = 1880
      w.width = width
      w.height = height
      w.megatile_width = 3
      w.megatile_height = 3
    end
    puts "Created '#{world.name}' with id #{world.id}" if debug

    puts "Spawning empty tiles" if debug
    world.spawn_tiles debug
    puts "\t...done" if debug

    self.place_resources(world, debug)
    self.create_users_and_players(world, debug)
    self.create_starter_property(world, debug)

    return world
  end  #build_example_world

  private
  def self.place_resources(world, debug=false)

    how_many_trees = (world.width * world.height * 0.40).round
    print "Placing resources" if debug
    STDOUT.flush

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
        print '.' if debug
        STDOUT.flush if debug
      end
    end
    puts '' if debug
  end #place_resources

  def self.create_users_and_players(world, debug)
    #puts "Creating users and players..."
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
      puts "\tPlayer id #{p.id} (#{p.type}) created" if debug
    end
  end #create_users

  def self.create_starter_property(world, debug)
    print "Assigning starter property" if debug
    ((world.width / 6) * (world.height / 6)).times do
      x = rand world.width
      y = rand world.height
      megatile = world.megatile_at x,y
      megatile.owner = world.players[rand(world.players.count)]
      megatile.save
      print "." if debug
      STDOUT.flush
    end
    puts "" if debug
  end
end #class

