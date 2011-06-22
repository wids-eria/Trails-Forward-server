class TransferChangeRequest < ChangeRequest
  validate :target_must_be_a_bid
  attr_accessor :world, :target

  def target_must_be_a_bid
    errors.add(:target, "must be a Bid") unless target.class == Bid
  end

end