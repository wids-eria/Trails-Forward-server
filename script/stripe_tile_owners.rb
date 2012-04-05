# set the ownership of the world to player 1, left 1/3rd. player 2, right
# 1/3rd. middle unowned

World.all.each do |world|
  if world.players.count < 2
    puts "world #{world.id} skipping, less than 2 players"
    next
  end
  first_boundary = world.width/3
  first_player = world.players.first.id
  puts "world #{world.id} player #{first_player} to owner of x < #{first_boundary}"
  world.megatiles.update_all "owner_id = #{first_player}", "x < #{first_boundary}"

  second_boundary = (world.width/3.0)*2
  second_player = world.players[1].id
  puts "world #{world.id} player #{second_player} to owner of x > #{second_boundary}"
  world.megatiles.update_all "owner_id = #{second_player}", "x > #{second_boundary}"
end
