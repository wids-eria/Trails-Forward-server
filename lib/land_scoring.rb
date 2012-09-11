module LandScoring
  Desirability_score_cap = 10

  Martin_presence_score = 2
  Tree_presence_score_scalar = 2.0
  Occupancy_score_scalar = -2.0
  Housing_score_scalar = -2.0
  
  Maximum_basal_area = 280.0
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
  end
  
  def calculate_local_desirability_score   
    if self.base_cover_type == :water
      2
    else
      score = 0
      score += Martin_presence_score if is_marten_suitable?
      if can_clearcut?
        basal_area = calculate_basal_area tree_sizes, collect_tree_size_counts
        score += Tree_presence_score_scalar * basal_area / Maximum_basal_area
      end
      score += Housing_score_scalar * self.housing_occupants/100.0 if self.housing_occupants  
      score += case self.base_cover_type
        when :forest
          1
        when :wetland
          1
        when :barren
          -1
        else
          0
      end
      score
    end
  end
  
  def calculate_total_desirability_score
    ret = 0
    neighbors.each do |rt|
      ret += rt.local_desirability_score
    end
    if ret < Desirability_score_cap
      ret
    else
      Desirability_score_cap
    end
  end  
  
  def update_local_desirability_score
    self.local_desirability_score = calculate_local_desirability_score
  end
  
  def update_total_desirability_score
    self.total_desirability_score = calculate_total_desirability_score
  end
  
  def update_total_desirability_score!
    update_total_desirability_score
    save!
  end
  
  def martins_are_present?
    self.agents.for_type(:marten).count > 0
  end
  
end