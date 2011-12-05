require 'csv'

def handle_row(row, indices, world)
  x = row[ indices[:col] ].to_i
  y = row[ indices[:row] ].to_i
  print "Handling #{x}, #{y}: "

  resource_tile = world.resource_tile_at x,y

  resource_tile.skip_version! do # speed things up... since it's Genesis, we should't ever need to rollback

    frontage = row[ indices[:frontage] ].to_f
    resource_tile.frontage = frontage

    lakesize = row[ indices[:lakesize] ].to_f
    resource_tile.lakesize = lakesize

    soil = row[ indices[:soil] ].to_i
    resource_tile.soil = case soil
                         when 255 then nil
                         else soil
                         end

    puts "frontage=#{resource_tile.frontage} lakesize=#{resource_tile.lakesize} soil=#{resource_tile.soil}"

  end

end

world = World.find ARGV[0]
reader = CSV.open("misc/data/vilas_conserv_game_spatial_1_acre_inputs2.csv", "r")
header = reader.shift
indices = {:row => header.index("ROW"), :col => header.index("COL"), :frontage => header.index("FRONTAGE"), :lakesize => header.index("LAKESIZE"), :soil => header.index("SOIL")}
reader.each{|row| handle_row(row, indices, world)}
