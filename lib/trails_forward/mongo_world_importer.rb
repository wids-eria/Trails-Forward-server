require 'bamfcsv'
require 'progressbar'
require 'stats_utilities'
require File.join(Rails.root, 'lib', 'trails_forward', 'coordinate_utilities')
require File.join(Rails.root, 'lib', 'trails_forward', 'tile_creation_utilities')

### NOTE work in progress to refactor, and remove db specific actions

module TrailsForward
  module MongoWorldImporter
    include CoordinateUtilities
    include TileCreationUtilities

    ### TODO import orm specific mixin here? with an api for each to abstract importing records. (mass hash array vs single vs batch)

    attr_accessor :filename, :csv_rows, :mega_tile_ids
    attr_accessor :world, :resource_tiles, :mega_tiles, :players

    def import_world filename
      ProgressBar.color_status
      ProgressBar.iter_rate_mode

      self.filename = filename

      process_csv
      create_world
      create_mega_tiles
      import_resource_tiles
      create_players

      puts "DING!"
    end



    ### IMPORT METHODS ###################

    def process_csv
      progress = ProgressBar.new 'CSV Parse', 1
      self.csv_rows = BAMFCSV.read(filename)
      progress.finish

      header = csv_rows.shift
      @col_numbers = {:row => header.index("ROW"),
                      :col => header.index("COL"),
                      :cover_class => header.index("LANDCOV2001"),
                      :imperviousness => header.index("IMPERV%2001"),
                      :devel_density => header.index("HDEN00"),
                      :forest_density => header.index("CANOPY%2001"),
                      :frontage => header.index("FRONTAGE"),
                      :lakesize => header.index("LAKESIZE"),
                      :soil => header.index("SOIL"),
                      :zoning => header.index("ZONING")}
    end


    def create_world
      x_col = @col_numbers[:col]
      y_col = @col_numbers[:row]

      world_width = csv_rows.last[x_col].to_i + 1
      world_height = csv_rows.last[y_col].to_i + 1

      world_width -= world_width % 3
      world_height -= world_height % 3

      name = File.basename(filename).sub(/\.csv$/, '')

      progress = ProgressBar.new 'World', 1
      self.world = MongoWorld.new width: world_width, height: world_height, name: name, mega_tile_width: 3, mega_tile_height: 3
      self.world.save
      world_id = world.id
      progress.finish
    end


    def create_mega_tiles
      coordinate_list = collect_coordinates(world.width, world.height, :step => world.mega_tile_height)

      progress = ProgressBar.new('MegaTiles', coordinate_list.count) if Rails.env.development?
      self.mega_tiles = coordinate_list.collect do |x, y|
        tile = MongoMegaTile.new x: x, y: y, world: world
        tile.save
        progress.inc
        tile
      end
      progress.finish

      cache_mega_tile_ids
    end


    def cache_mega_tile_ids
      progress = ProgressBar.new('MegaTile $', mega_tiles.count)
      self.mega_tile_ids = {}
      mega_tiles.each do |megatile|
        self.mega_tile_ids["#{megatile.x}:#{megatile.y}"] = megatile.id
        progress.inc
      end
      progress.finish
    end


    def import_resource_tiles
      progress = ProgressBar.new('ResourceTiles', mega_tiles.count)
      csv_rows.each do |row|
        row_hash = csv_row_to_hash(row)
        record_attributes = tile_attribute_hash_from_row_hash(row_hash) 
        tile = MongoResourceTile.new record_attributes 
        tile.save
        progress.inc
      end
      progress.finish
    end


    def create_players
    end



    ### HELPERS ##########################


    def tile_attribute_hash_from_row_hash row_hash
      tile_x = row_hash[:col].to_i
      tile_y = row_hash[:row].to_i
      landcover_code = row_hash[:cover_class].to_i

      mega_tile_x = tile_x - (tile_x % world.mega_tile_width)
      mega_tile_y = tile_y - (tile_y % world.mega_tile_height)
      mega_tile_id = mega_tile_ids["#{mega_tile_x}:#{mega_tile_y}"]
      raise("Missing mega_tile at #{mega_tile_x}:#{mega_tile_y}") if mega_tile_id.nil?

      tile_hash = { world_id: world.id, mega_tile_id: mega_tile_id, x: tile_x, y: tile_y }

      tile_hash[:tree_density] = tree_density_percent(row_hash[:forest_density].to_f)
      tile_hash[:housing_density] = housing_density_percent(row_hash[:devel_density].to_f)
      tile_hash[:imperviousness] = imperviousness_percent(row_hash[:imperviousness].to_f)
      tile_hash[:frontage] = row_hash[:frontage].to_f
      tile_hash[:lakesize] = row_hash[:lakesize].to_f
      tile_hash[:soil] = soil_amount(row_hash[:soil].to_i)
      tile_hash[:landcover_class_code] = landcover_code
      tile_hash[:land_cover_type] = ResourceTile.landcover_description(landcover_code)

      case landcover_code
      when 21..24 # Developed
        tile_hash[:development_intensity] = (landcover_code - 20.0 / 4.0)
      when 41,42,43,51,52,71,90 # Forest types, Scrub, Herbaceous
        tile_hash[:tree_size] = determine_tree_size(tile_hash[:land_cover_type])
      end

      tile_hash[:zoning_code] = row_hash[:zoning]
      tile_hash[:primary_use] = primary_use(tile_hash)
      tile_hash[:_type] = tile_type(tile_hash)
      tile_hash
    end

    def csv_row_to_hash row
      result = {}
      @col_numbers.each do |k, v|
        result[k] = row[v]
      end
      result
    end

  end
end
