class MaleMarten < Marten

  TURN_SD = 90

  def tick
    forage
    check_death
    metabolize
    self.age += 1
  end




  # sex-specific sub-routines that feed into move_one_patch function 
      def move_one_patch
        marten_turn
        target = patch_ahead 1
        puts "TARGET = #{target.x}, #{target.y}"
        self.neighborhood = nearby_tiles :radius => 1
        #TODO: removes current tile from neighborhood - not sure if this approach is best, but otherwise will blow up 'face' atan2 function if move target = current tile
        tile_here = self.world.resource_tile_at self.x, self.y 
        self.neighborhood.delete_if{|tile| tile.id == tile_here.id}

        
        # check scent of patch ahead to see if it's someone else's
        # if near edge of world, target = nil
        if target.nil? == false and (target.residue.empty? or target.residue[:marten_id]==self.id)
          
          if habitat_suitability_for (target) == 1
            walk_forward 1
          else
          # entrance probability a function of hunger
            modified_patch_entrance_probability = (PATCH_ENTRANCE_PROBABILITY * (1 - (self.energy / MAX_ENERGY))) 
            if rand < modified_patch_entrance_probability
              walk_forward 1
            else
              select_forage_patch 
              walk_forward 1
            end
          end
        else
          modified_patch_entrance_probability = (PATCH_ENTRANCE_PROBABILITY * (1 - (self.energy / MAX_ENERGY))) 
          if rand < modified_patch_entrance_probability
            walk_forward 1
          end
        end
      end



      def marten_turn
        # different turn methods
        # random
          turn rand(360)
        #  correlated +
        #  turn self.normal_dist 0 self.turn_sd
        # correlated - 
        #  turn self.normal_dist 180 self.turn_sd
      end

        

      def set_neighborhood
        # determine surrounding tiles that are "suitable"
        # neighborhood = nearby_tiles :radius => 1   #TODO: probably don't need to reset this here; shouldn't go out of scope from marten.rb
        self.neighborhood = self.neighborhood.select {|tile| tile.residue[:marten_id].nil? or tile.residue[:marten_id]==self.id}
        self.neighborhood = self.neighborhood.select {|tile| habitat_suitability_for(tile) == 1}

#        neighborhood = habitat_suitability_for (neighborhood) == 1 #TODO: have to check approach to selecting 'suitable' tiles in neighborhood
      end

end
