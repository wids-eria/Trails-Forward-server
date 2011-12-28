#!/usr/bin/env ./script/rails runner
require 'bamfcsv'
require 'progressbar'

BASE_FILENAME = "script/data/vilas_conserv_game_spatial_1_acre_inputs_combined.csv"
ROW_BATCH_SIZE = 2000
PLAYER_TYPES = [Lumberjack, Developer, Conserver]

filename = ARGV[0] || BASE_FILENAME
name = File.basename(filename).sub(/\.csv$/, '')

ProgressBar.color_status
ProgressBar.iter_rate_mode
pb = ProgressBar.new 'CSV Parse', 1
rows = BAMFCSV.read(filename)
pb.finish

header = rows.shift
@col_numbers = {:row => header.index("ROW"),
                :col => header.index("COL"),
                :cover_class => header.index("LANDCOV2001"),
                :imperviousness => header.index("IMPERV%2001"),
                :devel_density => header.index("HDEN00"),
                :forest_density => header.index("CANOPY%2001"),
                :frontage => header.index("FRONTAGE"),
                :lakesize => header.index("LAKESIZE"),
                :soil => header.index("SOIL")}
x_col = @col_numbers[:col]
y_col = @col_numbers[:row]
row_hash = rows.index_by { |row| "#{row[x_col]}:#{row[y_col]}" }

world_width = rows.last[x_col].to_i + 1
world_height = rows.last[y_col].to_i + 1

world_width -= world_width % 3
world_height -= world_height % 3

pb = ProgressBar.new 'World', 1
world = Factory :world, width: world_width, height: world_height, name: name
world_id = world.id
pb.finish

world.spawn_megatiles

pb = ProgressBar.new 'Megatile IDs', world.megatiles.count
megatile_ids = {}
world.megatiles.find_in_batches do |megatiles|
  megatiles.each do |megatile|
    megatile_ids["#{megatile.x}:#{megatile.y}"] = megatile.id
    pb.inc
  end
end
pb.finish

def row_to_hash row
  result = {}
  @col_numbers.each do |k, v|
    result[k] = row[v]
  end
  result
end

def tree_density_percent density
  return 0.0 if density == 255.0
  density / 100.0
end

def housing_density_percent density
  case density
  when 1..6 then (2 ** (density + 1)) / 128.0
  else 0.0
  end
end

def imperviousness_percent density
  return 0.0 if density == 255.0
  density / 100.0
end

def soil_amount amount
  return nil if amount == 255
  amount
end

def developed_but_not_lived_in? tile_hash
  (tile_hash[:development_intensity] >= 0.5 || tile_hash[:imperviousness] >= 0.5) && tile_hash[:housing_density] <= 0.75
end

pb = ProgressBar.new 'Clear Tiles', 1
ResourceTile.delete_all world_id: world_id
pb.finish

import_columns = [ :megatile_id, :x, :y, :type, :zoned_use,
                   :world_id, :primary_use, :people_density,
                   :housing_density, :tree_density, :tree_species,
                   :development_intensity, :tree_size, :imperviousness,
                   :frontage, :lakesize, :soil, :landcover_class_code ]

pb = ProgressBar.new 'Tile Import', rows.count

rows.each_slice(ROW_BATCH_SIZE) do |row_batch|
  tiles_to_import = []

  row_batch.each do |row|
    row_hash = row_to_hash(row)
    class_code = row_hash[:cover_class].to_i

    tile_x = row_hash[:col].to_i
    tile_y = row_hash[:row].to_i
    next if tile_x >= world.width || tile_y >= world.height
    puts "[#{tile_x}, #{tile_y}]" if tile_x >= world.width || tile_y >= world.height

    megatile_x = tile_x % world.megatile_width
    megatile_y = tile_y % world.megatile_height
    megatile_id = megatile_ids["#{megatile_x}:#{megatile_y}"]

    tile_hash = { world_id: world_id,
                  type: 'LandTile',
                  megatile_id: megatile_id,
                  location: [tile_x, tile_y] }

    tile_hash[:tree_density] = tree_density_percent(row_hash[:forest_density].to_f)
    tile_hash[:housing_density] = housing_density_percent(row_hash[:devel_density].to_f)
    tile_hash[:imperviousness] = imperviousness_percent(row_hash[:imperviousness].to_f)
    tile_hash[:frontage] = row_hash[:frontage].to_f
    tile_hash[:lakesize] = row_hash[:lakesize].to_f
    tile_hash[:soil] = soil_amount(row_hash[:soil].to_i)
    tile_hash[:landcover_class_code] = class_code

    case class_code

    # Open Water, Emergent Herbaceous Wetlands
    when 11, 95
      if tile_hash[:housing_density] > 0
        tile_hash[:zoned_use] = "Development"
        tile_hash[:primary_use] = "Housing"
      else
        tile_hash[:type] = 'WaterTile'
      end

    # Developed
    when 21..24
      tile_hash[:zoned_use] = "Development"
      tile_hash[:development_intensity] = (class_code - 20.0 / 4.0)
      tile_hash[:primary_use] = developed_but_not_lived_in?(tile_hash) ? "Industry" : "Housing"

    # Barren land
    when 31
      # tile_hash[:zoned_use] = "Barren"

    # Forest, Scrub, Herbaceous, Wetlands
    when 41..71, 90
      tile_hash[:primary_use] = "Forest"
      tile_hash[:tree_species] = case class_code
                                 when 41 then ResourceTile.verbiage[:tree_species][:deciduous]
                                 when 42 then ResourceTile.verbiage[:tree_species][:coniferous]
                                 when 43 then ResourceTile.verbiage[:tree_species][:mixed]
                                 else ResourceTile.verbiage[:tree_species][:unknown]
                                 end
    # Farmland
    when 81..82
      tile_hash[:primary_use] = case class_code
                                when 81 then "Agriculture/Pasture"
                                when 82 then "Agriculture/Cultivated Crops"
                                end
      tile_hash[:zoned_use] = "Agriculture"

    # Off the end of the world, Water for now
    when 255
      tile_hash[:type] = 'WaterTile'

    else
      raise "Unknown tile class code #{class_code}"
    end

    tiles_to_import << import_columns.map { |col| tile_hash[col] }
    pb.inc
  end

  ResourceTile.import import_columns, tiles_to_import, validate: false, timestamps: false
end
pb.finish

pb = ProgressBar.new 'Players', PLAYER_TYPES.count
PLAYER_TYPES.each_with_index do |player_klass, idx|
  user = Factory :user,
    name: "User #{world_id}-#{idx}",
    email: "u#{world.id}-#{idx}@example.com"
  player = player_klass.create :user => user, :world => world, :balance => 1000
  pb.inc
end
pb.finish

puts "##{world_id} - #{name} generated".green
