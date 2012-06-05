class FemaleMarten < Marten

  TURN_SD = 90

  def tick 
    forage
    check_death
    metabolize
    attempt_reproduction
    self.age += 1
  end




  # sex-specific sub-routines that feed into move_one_patch function 
      def move_one_patch
        marten_turn
        self.target = patch_ahead 1
        self.neighborhood = nearby_tiles :radius => 1  #TODO: apparently this doesn't work for females
        #puts "Neighborhood size = #{self.neighborhood.length}"
        tile_here = self.world.resource_tile_at self.x, self.y 
        self.neighborhood.delete_if{|tile| tile.id == tile_here.id}

        if self.target.nil?
          select_forage_patch
        elsif habitat_suitability_for(self.target) == 1
        else
        # entrance probability a function of hunger
          modified_patch_entrance_probability = (PATCH_ENTRANCE_PROBABILITY * (1 - (self.energy / MAX_ENERGY))) 
          if rand < modified_patch_entrance_probability
          else
            select_forage_patch 
          end
        end
        face self.target
        walk_forward 1
      end



          def marten_turn
            # different turn methods
            # random
            #  turn rand(361)
            #  correlated +
              turn Agent.normal_dist std = TURN_SD, mean = 0
            # correlated - 
            # turn self.normal_dist 180 self.turn_sd
          end

            

      def set_neighborhood
        # determine surrounding tiles that are "suitable"
        self.neighborhood = self.neighborhood.select {|tile| habitat_suitability_for(tile) == 1}
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
