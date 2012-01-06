require 'bamfcsv'
require 'progressbar'
require 'stats_utilities'

### NOTE work in progress to refactor, and remove db specific actions

module TrailsForward
  module MongoWorldImporter
    ### TODO import orm specific mixin here? with an api for each to abstract importing records. (mass hash array vs single vs batch)

    attr_accessor :filename, :csv_rows, :mega_tile_ids
    attr_accessor :world, :resource_tiles, :mega_tiles, :players

    def self.import_world filename
      ProgressBar.color_status
      ProgressBar.iter_rate_mode

      self.filename = filename

      process_csv
      create_world
      create_mega_tiles
      import_resource_tiles
      create_players
    end



    ### IMPORT METHODS ###################

    def process_csv
      pb = ProgressBar.new 'CSV Parse', 1
      self.csv_rows = BAMFCSV.read(filename)
      pb.finish

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

      world_width = rows.last[x_col].to_i + 1
      world_height = rows.last[y_col].to_i + 1

      world_width -= world_width % 3
      world_height -= world_height % 3

      name = File.basename(filename).sub(/\.csv$/, '')

      pb = ProgressBar.new 'World', 1
      self.world = MongoWorld.new width: world_width, height: world_height, name: name
      world_id = world.id
      pb.finish
    end

    def create_mega_tiles
      cache_mega_tile_ids
    end

    def cache_mega_tile_ids
      pb = ProgressBar.new 'Megatile IDs', world.megatiles.count
      self.megatile_ids = {}
      megatiles.each do |megatile|
        megatile_ids["#{megatile.x}:#{megatile.y}"] = megatile.id
        pb.inc
      end
      pb.finish
    end

    def import_resource_tiles
    end

    def create_players
    end


  end
end
