module TrailsForward
  module TreeImporter
    # The idea here is to determine a corresponding target basal area based on the mean diameter size,
    def self.determine_target_basal_area
      # randomly assign for now, until Steve W. defines the desired logic
      (rand * 50) + 60
    end

    # exponential distribution of diameters;
    # ie.  (Meyer 1952, Goff and West 1975, Manion and Griffin 2001, Hitimana et al. 2004, Wang et al. 2009)
    def self.populate_with_uneven_aged_distribution tree_size, target_basal_area
      random_neg_exp = rand * 1.5 + 0.5

    # determine the probability of an individual being entered into each size class, based on a negative exponential distribution
      # start by creating class size values
      class_steps = (2..24).step(2)

      # calculate negative exponential value with random variation
      # negative_exponential_values = Math.exp(-random_neg_exp * class_steps)
      negative_exponential_values = class_steps.map{|n| Math.exp(-random_neg_exp * n)}

      # normalize to calculate probability of each class
      # class_probabilities = negative_exponential_values/sum(negative_exponential_values)
      negative_exponential_values_sum = negative_exponential_values.sum
      class_probabilities = negative_exponential_values.map{|n| n / negative_exponential_values_sum}

      # randomly place in each bin determined by random trial
      tile_basal_area = 0
      while tile_basal_area < target_basal_area
        diameter_bin = random_element class_steps, class_probabilities
        self.send("num_#{diameter_bin}_inch_diameter_trees=", self.send("num_#{diameter_bin}_inch_diameter_trees") + 1)

        # first, if diameter_bin < class_probabilities[1]
        # then concatenate("tile.diameter_size_class_2" = concatenate("tile.diameter_size_class_2") + 1
        # if class_probabilities[i-1] < diameter_bin && diameter_bin < class_probabilities
        # then concatenate("tile.diameter_size_class_" + diameter_bin) = concatenate("tile.diameter_size_class_" + diameter_bin) + 1
        tile_basal_area += 0.005454 * diameter_bin ** 2
      end
    end

    def self.populate_with_even_aged_distribution tile_hash, target_basal_area
      tree_size = tile_hash[:tree_size]
      default_all_tree_sizes_to_0 tile_hash
      tile_basal_area = 0

      # Randomly determine coefficient of variation: 0 - 1, mean ~ 0.2 (made up following Volker class notes)
      coeff_of_variation = ResourceTile.dist.beta(2, 5)

      # Calcualte standard deviation of diameter as a function of coeff of variation
      standard_deviation_of_diameter = coeff_of_variation * tree_size

      while tile_basal_area < target_basal_area
        # Calculate random size class, normally distributed around 'tree_size'
        diameter_bin = ResourceTile.dist.normal(tree_size, standard_deviation_of_diameter)

        if diameter_bin > 0 && diameter_bin < 29
          diameter_bin = select_bin_size diameter_bin

          # Update the count in the size class for this individual
          tile_hash["num_#{diameter_bin}_inch_diameter_trees".to_sym] = tile_hash["num_#{diameter_bin}_inch_diameter_trees".to_sym] + 1

          # Update running BA total (so it knows when to stop
          tile_basal_area += 0.005454 * diameter_bin ** 2
        end
      end
    end

    def self.default_all_tree_sizes_to_0 tile_hash
      (2..24).step(2).each do |n|
        tile_hash["num_#{n}_inch_diameter_trees".to_sym] = 0
      end
    end

    def self.select_bin_size diameter_bin
      if (diameter_bin <= 0) || (diameter_bin >= 29)
        nil
      elsif diameter_bin > 24
        24
      else
        result = diameter_bin.ceil
        if result.odd?
          result += 1
        end
        result
      end
    end
  end
end
