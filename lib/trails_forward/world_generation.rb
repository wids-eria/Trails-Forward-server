module TrailsForward
  module WorldGeneration
    def spawn_blank_tiles opts = {}
      opts.reverse_merge! populate: false

      raise "Can't spawn tiles for an invalid World" unless valid?
      ActiveRecord::Base.transaction do
        spawn_megatiles unless megatiles.any?
        spawn_resource_tiles opts
      end

      self
    end

    def spawn_megatiles
      megatile_list = megatile_coords.collect do |x, y|
        [x, y, id]
      end

      mt_progress_bar = ProgressBar.new('Megatiles', megatile_list.count / 1000) if Rails.env.development?
      megatile_list.each_slice(1000) do |megatile_slice|
        Megatile.import %w(x y world_id), megatile_slice,
          validate: false, timestamps: false

        mt_progress_bar.inc if Rails.env.development?
      end
      self.reload

      mt_progress_bar.finish if Rails.env.development?
    end

    def spawn_resource_tiles opts = {}
      opts.reverse_merge! populate: false
      rt_progress_bar = ProgressBar.new('Resource Tiles', megatiles.count / 100) if Rails.env.development?
      Megatile.find_in_batches(conditions: {world_id: id}, batch_size: 100) do |megatile_batch|
        batch_tiles = megatile_batch.collect do |tile_info|
          (0...megatile_width).collect do |x_offset|
            (0...megatile_height).collect do |y_offset|
              this_x = tile_info.x + x_offset
              this_y = tile_info.y + y_offset
              if opts[:populate]
                resource_gen [this_x, this_y], tile_info.id
              else
                [this_x, this_y, tile_info.id, id]
              end
            end
          end.inject(:+)
        end.inject(:+)

        if opts[:populate]
          ResourceTile.import batch_tiles, validate: false, timestamps: false
        else
          ResourceTile.import %w(x y megatile_id world_id), batch_tiles, validate: false, timestamps: false
        end

        rt_progress_bar.inc if Rails.env.development?
      end
      self.reload

      rt_progress_bar.finish if Rails.env.development?
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

    def resource_gen location, megatile_id
      case rand(9)
      when 0
        WaterTile.new world_id: id,
          location: location,
          megatile_id: megatile_id
      when 1..6
        deciduous_land_tile location, megatile_id
      else
        residential_land_tile location, megatile_id
      end
    end

    def deciduous_land_tile location, megatile_id 
        LandTile.new world_id: id,
          location: location,
          megatile_id: megatile_id,
          primary_use: nil,
          people_density: 0,
          housing_density: 0,
          tree_density: 0.5 + rand / 2.0,
          tree_size: 12.0,
          num_2_inch_diameter_trees: 2,
          num_4_inch_diameter_trees: 4,
          num_6_inch_diameter_trees: 6,
          num_8_inch_diameter_trees: 8,
          num_10_inch_diameter_trees: 10,
          num_12_inch_diameter_trees: 12,
          num_14_inch_diameter_trees: 10,
          num_16_inch_diameter_trees: 8,
          num_18_inch_diameter_trees: 6,
          num_20_inch_diameter_trees: 4,
          num_22_inch_diameter_trees: 2,
          num_24_inch_diameter_trees: 0,
          landcover_class_code: ResourceTile.cover_type_number(:deciduous),
          development_intensity: 0.0,
          zoning_code: 6
    end

    def deciduous_land_tile_variant location, megatile_id
        LandTile.new world_id: id,
          location: location,
          megatile_id: megatile_id,
          primary_use: nil,
          people_density: 0,
          housing_density: 0,
          tree_density: 0.5 + rand / 2.0,
          tree_size: 12.0,
          num_2_inch_diameter_trees: 48,
          num_4_inch_diameter_trees: 28,
          num_6_inch_diameter_trees: 22,
          num_8_inch_diameter_trees: 18,
          num_10_inch_diameter_trees: 14,
          num_12_inch_diameter_trees: 12,
          num_14_inch_diameter_trees: 10,
          num_16_inch_diameter_trees: 8,
          num_18_inch_diameter_trees: 6,
          num_20_inch_diameter_trees: 4,
          num_22_inch_diameter_trees: 2,
          num_24_inch_diameter_trees: 0,
          landcover_class_code: ResourceTile.cover_type_number(:deciduous),
          development_intensity: 0.0,
          zoning_code: 6
    end

    def residential_land_tile location, megatile_id
        people_density = 0.5 + rand / 2.0
        LandTile.new world_id: id,
          location: location,
          megatile_id: megatile_id,
          primary_use: "Residential",
          zoning_code: 12,
          people_density: people_density,
          housing_density: people_density,
          tree_density: rand * 0.1,
          development_intensity: people_density
    end

    def place_resources
      how_many_trees = (width * height * 0.40).round

      resource_progress_bar = ProgressBar.new('Resources', resource_tiles.count) if Rails.env.development?
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
          resource_tile.landcover_class_code = ResourceTile.cover_type_number(:deciduous)
          resource_tile.development_intensity = 0.0
          resource_tile.zoning_code = 6
        when 7..8
          resource_tile.primary_use = "Residential"
          resource_tile.zoning_code = 12
          resource_tile.people_density = 0.5 + rand()/2.0
          resource_tile.housing_density = resource_tile.people_density
          resource_tile.tree_density = rand() * 0.1
          resource_tile.land_cover_type = nil
          resource_tile.development_intensity = resource_tile.housing_density
        end
        resource_tile.save
        resource_progress_bar.inc if Rails.env.development?
      end
      resource_progress_bar.finish if Rails.env.development?
      self
    end

  end
end
