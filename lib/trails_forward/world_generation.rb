module TrailsForward
  module WorldGeneration
    def spawn_blank_tiles
      raise "Can't spawn tiles for an invalid World" unless valid?
      ActiveRecord::Base.transaction do
        spawn_megatiles unless megatiles.any?
        spawn_resource_tiles
      end

      self
    end

    def spawn_megatiles
      megatile_list = megatile_coords.collect do |x, y|
        [x, y, id]
      end

      mt_count = 0
      mt_total = (megatile_list.count / 1000)
      megatile_list.each_slice(1000) do |megatile_slice|
        report_percent("Megatiles", mt_total, mt_count)

        Megatile.import %w(x y world_id), megatile_slice,
          validate: false, timestamps: false

        mt_count += 1
      end
      self.reload

      puts "  Megatiles: 100%        ".green if Rails.env.development?
    end

    def spawn_resource_tiles
      rt_count = 0
      rt_total = megatiles.count / 1000
      Megatile.find_in_batches(conditions: {world_id: id}, batch_size: 1000) do |megatile_batch|
        report_percent("Resource tiles", rt_total, rt_count)

        batch_tiles = megatile_batch.collect do |tile_info|
          (0...megatile_width).collect do |x_offset|
            (0...megatile_height).collect do |y_offset|
              [tile_info.x + x_offset, tile_info.y + y_offset, tile_info.id, id]
            end
          end.inject(:+)
        end.inject(:+)

        ResourceTile.import %w(x y megatile_id world_id), batch_tiles, validate: false, timestamps: false

        rt_count += 1
      end
      self.reload

      puts "  Resource tiles: 100%         ".green if Rails.env.development?
    end

    def report_percent title, total, current
      if Rails.env.development?
        percent = (100.0 * current) / total
        puts("  #{title}: %.2f%%       ".green.and_go_up(1) % percent)
      end
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

    # def resource_gen
    #   case rand(9)
    #   when 0
    #     WaterTile.new world_id: id
    #   when 1..6
    #     LandTile.new world_id: id,
    #       primary_use: nil,
    #       people_density: 0,
    #       housing_density: 0,
    #       tree_density: 0.5 + rand / 2.0,
    #       tree_species: 'Deciduous',
    #       development_intensity: 0.0,
    #       zoned_use: (rand(10) == 0) ? "Logging" : ""
    #   else
    #     people_density = 0.5 + rand / 2.0
    #     LandTile.new world_id: id,
    #       primary_use: "Residential",
    #       zoned_use: "Development",
    #       people_density: people_density,
    #       housing_density: people_density,
    #       tree_density: rand * 0.1,
    #       development_intensity: people_density
    #   end
    # end

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

  end
end
