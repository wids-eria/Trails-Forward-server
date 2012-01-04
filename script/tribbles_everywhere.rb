#!/usr/bin/env ./script/rails runner
require 'benchmark'
require "tattletail"

num_ticks = ARGV[1] || 100
num_ticks = num_ticks.to_i
num_tribbles = 100
world_width = 198
world_height = 198
tick_tiles = true
generate_pngs = true

def file_prefix world
  "doc/world_pngs/#{world.id}-#{world.name.gsub(/\s/, '_')}"
end

def clear_old_pngs world
  files = Dir.glob("#{file_prefix world}*.png")
  files.each do |file|
    File.delete(file)
  end
end

def create_png world, tick_count
  file_name = "#{file_prefix world}-%03d.png" % tick_count
  world.generate_png file_name
end

def create_gif world
  file_name = "#{file_prefix world}.gif"
  File.delete(file_name) if File.exists?(file_name)
  system "convert #{file_prefix world}-*.png #{file_name}"
end

def set_progress_title tick_progress_bar, tick_count, agent_count
  tick_progress_bar.title = "Tick #{tick_count + 1} - #{agent_count} Tribbles" if Rails.env.development?
end

def tribbles_in_world world
  Tribble.with_world_and_tile.where(world_id: world.id)
end

world = if ARGV[0]
          World.find(ARGV[0])
        else
          Factory :world_with_resources, width: world_width, height: world_height
        end
tribbles_in_world(world).delete_all

world_width = world.width
world_height = world.height
tick_count = 0
ind_tick_count = 0
tick_tiles = true
generate_pngs = true

ProgressBar.color_status
ProgressBar.iter_rate_mode
ProgressBar.disable_output unless Rails.env.development?

tribble_pb = ProgressBar.new('Tribbles', num_tribbles)

num_tribbles.times do
  location = []
  resource_tile = ''
  begin
    location = [rand * world_width, rand * world_height]
    resource_tile = world.resource_tile_at(*location.map(&:floor))
  end until resource_tile.type == 'LandTile' && resource_tile.tree_density > 0.4
  tribble = Factory.create :tribble,
                            world: world,
                            location: location,
                            heading: rand(360).round,
                            age: [Agent.normal_dist(2,5), 0].max.floor
  tribble_pb.inc
end
tribble_pb.finish

clear_old_pngs world
create_png(world, tick_count) if generate_pngs

puts

tile_count = LandTile.where(world_id: world.id).where('tree_density IS NOT NULL').count

tick_complete_stalk = Beanstalk::Pool.new(['localhost:11300'], 'agent.tick.complete')

num_ticks.times do |n|

  tick_pb = ProgressBar.new("Tick #{tick_count + 1} - Tribbles", tribbles_in_world(world).count)
  set_progress_title(tick_pb, tick_count, tribbles_in_world(world).count)
  tick_pb.expand_title
  tick_pb.colorize :magenta

  age_pb = ProgressBar.new("Tick #{tick_count + 1} - Age", 1)
  world.age_agents!
  age_pb.inc
  age_pb.finish

  litter = []

  tribble_count = tribbles_in_world(world).count
  tribbles_in_world(world).each do |tribble|
    Stalker.enqueue 'agent.tick', agent_id: tribble.id
  end

  tribble_count.times do
    job = tick_complete_stalk.reserve
    job.delete
    tick_pb.inc
  end
  set_progress_title(tick_pb, tick_count, tribbles_in_world(world).count)
  tick_pb.expand_title
  tick_pb.finish

  if tick_tiles
    sql_pb = ProgressBar.new("Tick #{tick_count + 1} - Growth", 1)
    world.grow_trees!
    sql_pb.inc
    sql_pb.finish

    tile_pb = ProgressBar.new("Tick #{tick_count + 1} - Tiles", tile_count)
    tile_pb.expand_title
    tile_pb.colorize :blue
    LandTile.where(world_id: world.id).find_in_batches do |tile_batch|
      tile_batch.each do |tile|
        tile.tick!
        tile_pb.inc
      end
    end
    tile_pb.finish
  end

  tick_count += 1

  if generate_pngs
    create_png(world, tick_count)
    create_gif world
  end
  puts
end
