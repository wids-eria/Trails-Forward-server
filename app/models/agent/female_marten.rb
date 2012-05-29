class FemaleMarten < Marten

  TURN_SD = 90

  def go
    set actual_distance 0
    forage
    check_death
    metabolize
    attempt_reproduction
    self.age += 1
  end




  # sex-specific sub-routines that feed into move_one_patch function 
      def move_one_patch
        marten_turn
        target = patch_ahead 1
        neighborhood = nearby_tiles 1
        
          
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
      end



          def marten_turn
            # different turn methods
            # random
            #  turn rand(361)
            #  correlated +
              turn self.normal_dist(0, self.turn_sd)
            # correlated - 
            # turn self.normal_dist 180 self.turn_sd
          end

            

      def set_neighborhood
        # determine surrounding tiles that are "suitable"
        neighborhood = nearby_tiles.select {|tile| habitat_suitlability_for(tile) == 1} #TODO: have to check approach to selecting 'suitable' tiles in neighborhood
      end



      def attempt_reproduction
        # if individual is > 1 year old
        if self.age > 365
          # if individual is < 2 years old, 50% chance of rearing
          if self.age < 730
            if rand < 0.5 
              reproduce
            end
          # if individaul is > 2 years old, 80% chance of rearing
          else
            if rand < 0.8 
              reproduce
            end
          end
        end
      end



          def reproduce
            number_offspring(rand 5) + 1
            while number_offspring > 0 do
             # not sure how to create new agent of class marten, but it should do the following
              # reproduction behavior doesn't seem to fit very well
              if random < 0.5
                MaleMarten.create!(energy: MAX_ENERGY)
              else
                FemalMarten.create!(energy: MAX_ENERGY)
              end
              age 0
            end
          end

end
