
upgrowth_p = {
  shade_tolerant: [0.0164, -0.0001, 0.0055, -0.0002, 0],
  mid_tolerant: [0.0134, -0.0002, 0.0051, -0.0002, 0.00002],
  shade_intolerant: [0.0069, -0.0001, 0.0059, -0.0003, 0]
  }

mortality_p = {
  shade_tolerant: [0.0336, 0, -0.0018, 0.0001, 0.00002],
  mid_tolerant: [0.0417, 0, -0.0033, 0.0001, 0],
  shade_intolerant: [0.0418, 0, -0.009, 0, 0]
  }

ingrowth_p = {
  shade_tolerant: [18.187, -0.097],
  mid_tolerant: [4.603, -0.035],
  shade_intolerant: [7.622, -0.059]
  }

height_p = {
  shade_tolerant: [5.34, -0.23, 1.15, 0.54, 0.83, 0.06],
  mid_tolerant: [7.19, -0.28, 1,44, 0.39, 0.83, 0.11],
  shade_intolerant: [6.43, -0.24, 1.34, 0.47, 0.73, 0.08]
  }

volume_p = {
  shade_tolerant: [1.375, 0.002],
  mid_tolerant: [0, 0.002],
  shade_intolerant: [2.706, 0.002]
  }


def calculate_basal_area(dia_dist_hash)
end

# Tree Growth Equations

  # Describes the yearly proportion of trees moving from one diameter class to the next
  def upgrowth_rate(diameter, species_group, site_index, basal_area)
    upgrowth = upgrowth_p[species_group][0] + upgrowth_p[species_group][1] * basal_area + upgrowth_p[species_group][2] * diameter + upgrowth_p[species_group][3] * diameter ** 2 + upgrowth_p[species_group][4] * site_index * diameter
  end

  # Describes the yearly proportion of trees in a diameter class that die
  def mortality_rate(diameter, species_group, site_index)
    mortality = mortality_p[species_group][0] + mortality_p[species_group][1] * diameter + mortality_p[species_group][2] * diameter**2 + mortality_p[species_group][3] * site_index * diameter
  end

  # Describes the number of trees entering the smallest diameter class
  def ingrowth_number(basal_area)
    ingrowth = ingrowth_p[species_group][0] + ingrowth_p[species_group][1]
  end


# Tree Volume Equations

  # assumes that that we want to calculate volume in board-feet; otherwise, replace 9 with 4 to calculate cubic foot volume
  def merchantable_tree_height(diameter, species_group, site_index, basal_area)
    height = 4.5 + height_p[species_group][0] * (1-Math.exp(-height_p[species_group][1])) ** height_p[species_group][2] * site_index ** height_p[species_group][3] * (1.00001 - 9/diameter) ** height_p[species_group][4] * basal_area ** height_p[species_group][5]
  end

  def tree_volume(diameter, height)
    volume = volume_p[species_group][0] + volume_p[species_group][1]
  end
