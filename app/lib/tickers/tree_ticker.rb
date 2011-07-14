require 'narray'
require 'matrix_utils'
require 'ticker_utils'

class TreeTicker
  def self.tick(world)
  
    # get tree data for world 
    @old_tree_size = NArray.float(world.width, world.height)
    @decid = NArray.float(world.width, world.height)
    @conifer = NArray.float(world.width, world.height)
    @mixed = NArray.float(world.width, world.height)
    @old_tree_size.fill!(0.0)
    @decid.fill!(0.0)
    @conifer.fill!(0.0)
    @mixed.fill!(0.0)
    
    ResourceTile.where(:world_id => world.id).find_in_batches do |group|
      group.each do |rt|
        x = rt.x
        y = rt.y
        case rt.tree_species
          when ResourceTile::Verbiage[:tree_species][:deciduous]
            @decid[x,y] = rt.tree_size
            @old_tree_size[x,y] = rt.tree_size
          when ResourceTile::Verbiage[:tree_species][:coniferous]
            @conifer[x,y] = rt.tree_size
            @old_tree_size[x,y] = rt.tree_size
          when ResourceTile::Verbiage[:tree_species][:mixed]
            @mixed[x,y] = rt.tree_size
            @old_tree_size[x,y] = rt.tree_size
        end #case
      end #group
    end #find_in_batches


    # compute the tree growth
    result = compute_timber @decid, @conifer, @mixed, 1
    
    # debug code
    #puts "Old Tree Size"
    #print_Matrix @old_tree_size, @old_tree_size.shape[0], @old_tree_size.shape[1]
    #puts "New Tree Size"
    #print_Matrix result.tree_size, result.tree_size.shape[0], result.tree_size.shape[0]
    
    
    # update the trees
    LandTile.where(:world_id => world.id).find_in_batches do |group|
      group.each do |rt|
        x = rt.x
        y = rt.y
        case rt.tree_species
          when ResourceTile::Verbiage[:tree_species][:deciduous]
            rt.tree_size = result.tree_size[x,y]
          when ResourceTile::Verbiage[:tree_species][:coniferous]
            rt.tree_size = result.tree_size[x,y]
          when ResourceTile::Verbiage[:tree_species][:mixed]
            rt.tree_size = result.tree_size[x,y]
        end #case
        rt.save!
      end #group
    end

  end

end
