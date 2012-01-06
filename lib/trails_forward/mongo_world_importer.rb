require 'bamfcsv'
require 'progressbar'
require 'stats_utilities'
require File.join(Rails.root, 'lib', 'trails_forward', 'coordinate_utilities')

### NOTE work in progress to refactor, and remove db specific actions

module TrailsForward
  module MongoWorldImporter
    include CoordinateUtilities
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
    end


    def create_players
    end


  end
end
