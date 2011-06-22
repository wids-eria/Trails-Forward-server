class ConstructionChangeRequest < ChangeRequest
  validate :target_must_be_land
  attr_accessor :world, :target, :development_type, :development_quality

  AllowedTargets = [Megatile, LandTile, MegatileGrouping]

  def target_must_be_land
    errors.add(:target, "must be a ResourceTile, Megatile, or MegatileGroup") unless AllowedTargets.include? target.class
  end

end