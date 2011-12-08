class ConstructionChangeRequest < ChangeRequest
  validate :target_must_be_land
  attr_accessor :world, :target, :development_type, :development_quality

  def self.allowed_targets
    [Megatile, LandTile, MegatileGrouping]
  end

  def target_must_be_land
    errors.add(:target, "must be a ResourceTile, Megatile, or MegatileGroup") unless ConstructionChangeRequest.allowed_targets.include? target.class
  end

end
