class TreeTicker
  def self.tick(world)
    LandTile.where(:world_id => world.id).find_in_batches do |group|
      group.each do |rt|
        rt.grow_trees
        rt.save!
      end
    end
  end
end