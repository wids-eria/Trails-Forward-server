module TrailsForward
  module WorldGeneration
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
                                                balance: Player.default_balance)
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
  end
end
