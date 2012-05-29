class MaleMarten < Marten

  TURN_SD = 90

  def go
    set actual_distance 0
    forage
    check-death
    metabolize
    self.age += 1
  end




  # sex-specific sub-routines that feed into move_one_patch function 
      def move_one_patch
        marten_turn
        target = patch_ahead 1
        neighborhood = nearby_tiles 1
        
        # check scent of patch ahead to see if it's someone else's
        if (target.residue[:marten_id].nil? or target.residue[:marten_id]==self.id)
          
          if habitat_suitability_for (target) == 1
            walk_forward 1
          else
          # entrance probability a function of hunger
            modified_patch_entrance_probability = (patch_entrance_probability * (1 - (self.energy / max-energy))) 
            if rand < modified_patch_entrance_probability
              walk_forward 1
            else
              select_forage_patch 
              walk_forward 1
            end
          end
        else
          modified_patch_entrance_probability = (patch_entrance_probability * (1 - (self.energy / max-energy))) 
          if rand < modified_patch_entrance_probability
            walk_forward 1
          end
        end
      end



      def marten_turn
        # different turn methods
        # random
          turn rand(361)
        #  correlated +
        #  turn self.normal_dist 0 self.turn_sd
        # correlated - 
        #  turn self.normal_dist 180 self.turn_sd
      end

        

      def set_neighborhood
        # determine surrounding tiles that are "suitable"
        neighborhood = nearby_tiles.select {tile.residue[:marten_id].nil? or tile.residue[:marten_id]==self.id}
        neighborhood = habitat_suitability_for (neighborhood) == 1 #TODO: have to check approach to selecting 'suitable' tiles in neighborhood
      end

end
