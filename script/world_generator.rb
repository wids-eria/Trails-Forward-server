#!/usr/bin/env ./script/rails runner
require 'bamfcsv'
require 'progressbar'
require 'stats_utilities'

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

# TODO: revisit forested_wetland weights, since the values here are simply
# copied from mixed. 12/30/11

DefaultTreeSizes = [10, 8, 5]
DefaultTreeSizeWeights = {
  coniferous: [0.556035896, 0.258728096, 0.185236008],
  deciduous: [0.43, 0.37, 0.2],
  forested_wetland: [0.424745355, 0.350450241, 0.224804403],
  mixed: [0.424745355, 0.350450241, 0.224804403]
}

BigTreeSizes = [0,2,4,6,8,10,15,20]
BigTreeSizeWeights = {
  coniferous: [0.372470808,0.216336587,0.104601339,0.107220868,0.063811891,0.053101396,0.079521954,0.002935158],
  deciduous: [0.473433437,0.271229523,0.127051152,0.068338135,0.029715297,0.011826016,0.01840644,0],
  forested_wetland: [0.369033307,0.232593812,0.114078886,0.10555826,0.061401365,0.046739204,0.068313732,0.002281434],
  mixed: [0.369033307,0.232593812,0.114078886,0.10555826,0.061401365,0.046739204,0.068313732,0.002281434],
}

def determine_tree_size land_cover_type
  case land_cover_type
  when 'Coniferous', 'Deciduous', 'Forested Wetland', 'Mixed'
    cover_type_symbol = land_cover_type.underscore.sub(' ', '_').to_sym
    calculate_tree_size cover_type_symbol
  when'Dwarf Scrub', 'Grassland/Herbaceous', 'Shrub/Scrub'
    nil
    # tile.update_attributes(tree_size: nil)
  when nil
    nil
  else
    raise "Unrecognized land_cover_type: #{land_cover_type}"
  end
end

def calculate_tree_size cover_type_symbol
  if cover_type_symbol.present?
    tree_size = random_element(DefaultTreeSizes, DefaultTreeSizeWeights[cover_type_symbol])

    if tree_size == 10
      tree_size += random_element(BigTreeSizes, BigTreeSizeWeights[cover_type_symbol])
    end
  else
    tree_size = nil
  end
  tree_size
end

def zoned_use tile_hash
  case tile_hash[:landcover_class_code]
  when 11, 95 # Open Water, Emergent Herbaceous Wetlands
    'Development' if tile_hash[:housing_density] > 0
  when 21..24 # Developed
    'Development'
  when 81,82 # Farmland
    'Agriculture'
  end
end

def primary_use tile_hash
  case tile_hash[:landcover_class_code]
  when 11, 95 # Open Water, Emergent Herbaceous Wetlands
    'Housing' if tile_hash[:housing_density] > 0
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

def tile_type(tile_hash)
  case tile_hash[:landcover_class_code]
  when 11, 95 # Open Water, Emergent Herbaceous Wetlands
    if tile_hash[:housing_density] <= 0
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
# tile_indices = ResourceTile.connection.indexes :resource_tiles
# pb = ProgressBar.new "Remove Indices", tile_indices.count
# tile_indices.each do |index|
#   ResourceTile.connection.remove_index index.table, index.columns
#   pb.inc
# end
# pb.finish

pb = ProgressBar.new 'Clear Tiles', 1
ResourceTile.delete_all world_id: world_id
pb.finish

import_columns = [ :megatile_id, :x, :y, :type, :zoned_use,
                   :world_id, :primary_use, :people_density,
                   :housing_density, :tree_density, :land_cover_type,
                   :development_intensity, :tree_size, :imperviousness,
                   :frontage, :lakesize, :soil, :landcover_class_code ]

pb = ProgressBar.new 'Tile Import', rows.count

ResourceTile.connection.transaction do
  rows.each_slice(ROW_BATCH_SIZE) do |row_batch|
    tiles_to_import = []

    row_batch.each do |row|
      row_hash = row_to_hash(row)
      landcover_code = row_hash[:cover_class].to_i

      tile_x = row_hash[:col].to_i
      tile_y = row_hash[:row].to_i
      next if tile_x >= world.width || tile_y >= world.height

      puts "[#{tile_x}, #{tile_y}]" if tile_x >= world.width || tile_y >= world.height

      megatile_x = tile_x % world.megatile_width
      megatile_y = tile_y % world.megatile_height
      megatile_id = megatile_ids["#{megatile_x}:#{megatile_y}"]

      tile_hash = { world_id: world_id,
                    megatile_id: megatile_id,
                    x: tile_x,
                    y: tile_y }

      tile_hash[:tree_density] = tree_density_percent(row_hash[:forest_density].to_f)
      tile_hash[:housing_density] = housing_density_percent(row_hash[:devel_density].to_f)
      tile_hash[:imperviousness] = imperviousness_percent(row_hash[:imperviousness].to_f)
      tile_hash[:frontage] = row_hash[:frontage].to_f
      tile_hash[:lakesize] = row_hash[:lakesize].to_f
      tile_hash[:soil] = soil_amount(row_hash[:soil].to_i)
      tile_hash[:landcover_class_code] = landcover_code

      case landcover_code
      when 21..24 # Developed
        tile_hash[:development_intensity] = (landcover_code - 20.0 / 4.0)

      when 41,42,43,51,52,71,90 # Forest types, Scrub, Herbaceous
        tile_hash[:land_cover_type] = ResourceTile.landcover_description(landcover_code)
        tile_hash[:tree_size] = determine_tree_size(tile_hash[:land_cover_type])
      end

      tile_hash[:zoned_use] = zoned_use(tile_hash)
      tile_hash[:primary_use] = primary_use(tile_hash)
      tile_hash[:type] = tile_type(tile_hash)

      tiles_to_import << import_columns.map { |col| tile_hash[col] }
      pb.inc
    end

    ResourceTile.import import_columns, tiles_to_import, validate: false, timestamps: false
  end
end
pb.finish

# pb = ProgressBar.new "Reapply indices", tile_indices.count
# tile_indices.each do |index|
#   ResourceTile.connection.add_index index.table, index.columns
#   pb.inc
# end
# pb.finish

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
