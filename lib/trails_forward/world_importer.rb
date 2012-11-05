require 'bamfcsv'
require 'progressbar'
require 'stats_utilities'

class NilProgressBar
  def self.color_status; end
  def self.iter_rate_mode; end
  def finish; end
  def inc; end
end

module TrailsForward
  module WorldImporter
    ROW_BATCH_SIZE = 2000
    PLAYER_TYPES = [Lumberjack, Developer, Conserver]
    
    CACHE_REGION_WIDTH = 10

    # TODO: revisit forested_wetland weights, since the values here are simply
    # copied from mixed. 12/30/11

    DefaultTreeSizes = [10, 8, 5]
    DefaultTreeSizeWeights = {
      coniferous: [0.556035896, 0.258728096, 0.185236008],
      deciduous: [0.43, 0.37, 0.2],
      forested_wetland: [0.424745355, 0.350450241, 0.224804403],
      mixed: [0.424745355, 0.350450241, 0.224804403]
    }

    LessFrequentTreeSizes = [0,2,4,6,8,10,15,20]
    LessFrequentTreeSizeWeights = {
      coniferous: [0.372470808,0.216336587,0.104601339,0.107220868,0.063811891,0.053101396,0.079521954,0.002935158],
      deciduous: [0.473433437,0.271229523,0.127051152,0.068338135,0.029715297,0.011826016,0.01840644,0],
      forested_wetland: [0.369033307,0.232593812,0.114078886,0.10555826,0.061401365,0.046739204,0.068313732,0.002281434],
      mixed: [0.369033307,0.232593812,0.114078886,0.10555826,0.061401365,0.046739204,0.068313732,0.002281434],
    }

    def self.row_to_hash row
      result = {}
      @col_numbers.each do |k, v|
        result[k] = row[v]
      end
      result
    end

    def self.tree_density_percent density
      return 0.0 if density == 255.0
      density / 100.0
    end

#    def self.housing_density_percent density
#      case density
#      when 1..6 then (2 ** (density + 1)) / 128.0
#      else 0.0
#      end
#    end

    def self.housing_density_percent density
      case density
      when 1..10 then (density / 10)
      else 0.0
      end
    end

    def self.imperviousness_percent density
      return 0.0 if density == 255.0
      density / 100.0
    end

    def self.soil_amount amount
      return nil if amount == 255
      amount
    end

    def self.developed_but_not_lived_in? tile_hash
      (tile_hash[:development_intensity] >= 0.5 || tile_hash[:imperviousness] >= 0.5) && tile_hash[:housing_type] == nil
    end

    def self.determine_tree_size land_cover_type
      case land_cover_type
      when 'Coniferous', 'Deciduous', 'Forested Wetland', 'Mixed'
        cover_type_symbol = land_cover_type.underscore.sub(' ', '_').to_sym
        calculate_tree_size cover_type_symbol
      when'Dwarf Scrub', 'Grassland/Herbaceous', 'Shrub/Scrub'
        0
      else
        raise "Unrecognized land_cover_type: #{land_cover_type}"
      end
    end

    def self.calculate_tree_size cover_type_symbol
      if cover_type_symbol.present?
        tree_size = random_element(DefaultTreeSizes, DefaultTreeSizeWeights[cover_type_symbol])

        if tree_size == 10
          tree_size += random_element(LessFrequentTreeSizes, LessFrequentTreeSizeWeights[cover_type_symbol])
        end
      else
        tree_size = nil
      end
      tree_size
    end

    def self.primary_use tile_hash
      case tile_hash[:landcover_class_code]
      when 11, 95 # Open Water, Emergent Herbaceous Wetlands
        'Housing' if tile_hash[:housing_type] != nil
      when 21..24 # Developed
        developed_but_not_lived_in?(tile_hash) ? "Industry" : "Housing"
      when 41,42,43,51,52,71,90 # Forest types
        "Forest"
      when 81
        'Agriculture/Pasture'
      when 82
        'Agriculture/Cultivated Crops'
      end
    end

    def self.tile_type(tile_hash)
      case tile_hash[:landcover_class_code]
      when 11, 95 # Open Water, Emergent Herbaceous Wetlands
        if tile_hash[:housing_type] == nil
          'WaterTile'
        else
          'LandTile'
        end
      when 255 # Off the end of the world, Water for now
        'WaterTile'
      else
        'LandTile'
      end
    end

    def self.tile_hash_from_row world, megatile_ids, row_hash, tile_x, tile_y
      landcover_code = row_hash[:cover_class].to_i

      megatile_x = tile_x - (tile_x % world.megatile_width)
      megatile_y = tile_y - (tile_y % world.megatile_height)
      megatile_id = megatile_ids["#{megatile_x}:#{megatile_y}"]
      raise("Missing megatile at #{megatile_x}:#{megatile_y}") if megatile_id.nil?

      tile_hash = { world_id: world.id, megatile_id: megatile_id, x: tile_x, y: tile_y }

      tile_hash[:tree_density] = tree_density_percent(row_hash[:forest_density].to_f)
      #tile_hash[:housing_density] = housing_density_percent(row_hash[:housing_density].to_f)
      #tile_hash[:housing_capacity] = housing_density_percent(row_hash[:house_count].to_f) * 100
      
      #set the housing type
      
      tile_hash[:housing_type] = case (housing_density_percent(row_hash[:house_count].to_f) * 100).to_i
        when nil, 0
          nil
        when 1..24
          LandTile::Vacation
        when 25..74
          LandTile::SingleFamily
        when 75..100
          LandTile::Apartment
        else
          raise 'unknown housing density'
      end
      
      tile_hash[:imperviousness] = imperviousness_percent(row_hash[:imperviousness].to_f)
      tile_hash[:frontage] = row_hash[:frontage].to_f
      tile_hash[:lakesize] = row_hash[:lakesize].to_f
      tile_hash[:soil] = soil_amount(row_hash[:soil].to_i)
      tile_hash[:landcover_class_code] = landcover_code
      tile_hash[:land_cover_type] = ResourceTile.landcover_description(landcover_code)

      case landcover_code
      when 21..24 # Developed
        tile_hash[:development_intensity] = ((landcover_code - 20.0) / 4.0)
      when 41,42,43,51,52,71,90 # Forest types, Scrub, Herbaceous
        tile_hash[:tree_size] = determine_tree_size(tile_hash[:land_cover_type])
        col_with_trees = "num_diameter_#{tile_hash[:tree_size]}_trees".to_sym
        tile_hash[col_with_trees] = determine_num_trees_from_tree_density tile_hash
      end

      tile_hash[:type] = tile_type(tile_hash)
      tile_hash[:zoning_code] = row_hash[:zoning]      
      tile_hash[:primary_use] = primary_use(tile_hash)

      #work around noisy data
      if tile_hash[:type] == "WaterTile"
        tile_hash[:housing_type] = nil
        tile_hash[:development_intensity] = 0
        tile_hash[:tree_density] = 0
        tile_hash[:tree_size] = 0
        tile_hash[:zoning_code] = 255
      end
      
      tile_hash
    end

    def self.determine_num_trees_from_tree_density tile_hash
      target_basal_area = TrailsForward::TreeImporter.determine_target_basal_area
      if rand < 0.5
        TrailsForward::TreeImporter.populate_with_even_aged_distribution tile_hash, target_basal_area
      else
        TrailsForward::TreeImporter.populate_with_uneven_aged_distribution tile_hash, target_basal_area
      end
    end

    # TODO: extract sub-methods to shrink this overly long method...
    def self.import_world filename, show_progress = true
      if show_progress
        progress_bar_class = ProgressBar
      else
        progress_bar_class = NilProgressBar
      end
      progress_bar_class.color_status
      progress_bar_class.iter_rate_mode
      pb = progress_bar_class.new 'CSV Parse', 1
      rows = BAMFCSV.read(filename)
      pb.finish

      header = rows.shift
      @col_numbers = {:row => header.index("ROW"),
                      :col => header.index("COL"),
                      :cover_class => header.index("LANDCOV2001"),
                      :imperviousness => header.index("IMPERV%2001"),
                      :house_count => header.index("HOUSES1996"),
                      :housing_density => header.index("HDEN00"),
                      :forest_density => header.index("CANOPY%2001"),
                      :frontage => header.index("FRONTAGE"),
                      :lakesize => header.index("LAKESIZE"),
                      :soil => header.index("SOIL"),
                      :zoning => header.index("ZONING")}

      x_col = @col_numbers[:col]
      y_col = @col_numbers[:row]
      row_hash = rows.index_by { |row| "#{row[x_col]}:#{row[y_col]}" }

      world_width = rows.last[x_col].to_i + 1
      world_height = rows.last[y_col].to_i + 1

      world_width -= world_width % 3
      world_height -= world_height % 3

      name = File.basename(filename).sub(/\.csv$/, '')

      pb = progress_bar_class.new 'World', 1
      world = Factory :world, width: world_width, height: world_height, name: name
      world_id = world.id
      
      world.pine_sawtimber_base_price = 0.147
      world.pine_sawtimber_supply_coefficient = 0.001
      world.pine_sawtimber_demand_coefficient = 0.001
      world.pine_sawtimber_min_price = 0.01
      world.pine_sawtimber_max_price = 1.0
      
      pb.finish

      world.spawn_megatiles


      pb = progress_bar_class.new 'Megatile IDs', world.megatiles.count
      megatile_ids = {}
      world.megatiles.find_in_batches do |megatiles|
        megatiles.each do |megatile|
          megatile_ids["#{megatile.x}:#{megatile.y}"] = megatile.id
          pb.inc
        end
      end
      pb.finish

      # tile_indices = ResourceTile.connection.indexes :resource_tiles
      # pb = progress_bar_class.new "Remove Indices", tile_indices.count
      # tile_indices.each do |index|
      #   ResourceTile.connection.remove_index index.table, index.columns
      #   pb.inc
      # end
      # pb.finish

      pb = progress_bar_class.new 'Clear Tiles', 1
      ResourceTile.delete_all world_id: world_id
      pb.finish

      import_columns = [ :megatile_id, :x, :y, :type, :zoning_code, :world_id,
                         :primary_use, #:people_density, :housing_density, :housing_capacity,
                         :housing_type,
                         :tree_density, :development_intensity, :tree_size,
                         :imperviousness, :frontage, :lakesize, :soil,
                         :landcover_class_code, :num_2_inch_diameter_trees,
                         :num_4_inch_diameter_trees, :num_6_inch_diameter_trees,
                         :num_8_inch_diameter_trees, :num_10_inch_diameter_trees,
                         :num_12_inch_diameter_trees, :num_14_inch_diameter_trees,
                         :num_16_inch_diameter_trees, :num_18_inch_diameter_trees,
                         :num_20_inch_diameter_trees, :num_22_inch_diameter_trees,
                         :num_24_inch_diameter_trees ]


      pb = progress_bar_class.new 'Tile Import', rows.count

      rows.each_slice(ROW_BATCH_SIZE) do |row_batch|
        ResourceTile.connection.transaction do
          tiles_to_import = []

          row_batch.each do |row|
            row_hash = row_to_hash(row)
            tile_x = row_hash[:col].to_i
            tile_y = row_hash[:row].to_i

            if tile_x < world.width && tile_y < world.height
              tile_hash = tile_hash_from_row world, megatile_ids, row_hash, tile_x, tile_y
              tiles_to_import << import_columns.map { |col| tile_hash[col] }
              pb.inc
            end
          end

          ResourceTile.import import_columns, tiles_to_import, validate: false, timestamps: false
        end
      end
      pb.finish

      first_id = world.resource_tile_at(0,0).id
      last_id = world.resource_tile_at(world.width - 1, world.height - 1).id
      puts "ID error #{last_id} - #{first_id - 1} != #{world.width} * #{world.height}" unless (first_id - 1) + world_width * world_height == last_id

      # pb = progress_bar_class.new "Reapply indices", tile_indices.count
      # tile_indices.each do |index|
      #   ResourceTile.connection.add_index index.table, index.columns
      #   pb.inc
      # end
      # pb.finish

#     pb = progress_bar_class.new 'Players', PLAYER_TYPES.count
#     PLAYER_TYPES.each_with_index do |player_klass, idx|
#       user = Factory :user,
#         name: "User #{world_id}-#{idx}",
#         email: "u#{world.id}-#{idx}@example.com"
#       player = player_klass.create :user => user, :world => world, :balance => 1000
#       pb.inc
#     end
#     pb.finish

      puts("##{world_id} - #{name} generated".green) if show_progress
      
      puts("Calculating desirability")
      #this shouldn't be necessary, but the importer doesn't do before_save callbacks
      pb = progress_bar_class.new 'Local desirability scores', world.width * world.height
      world.width.times do |x|
        world.height.times do |y|
          rt = world.resource_tile_at x, y
          rt.calculate_marten_suitability true if rt.type == 'LandTile'
          rt.save!
          pb.inc
        end
      end
      
      pb = progress_bar_class.new 'Total desirability scores', world.width * world.height
      world.width.times do |x|
        world.height.times do |y|
          rt = world.resource_tile_at x, y
          rt.update_total_desirability_score!
          pb.inc
        end
      end

      world.save!

      WorldPresenter.new(world).save_png
    end
  end
end
