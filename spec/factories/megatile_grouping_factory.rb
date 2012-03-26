FactoryGirl.define do
  factory :megatile_grouping do
    ignore do
      owner nil
      single_megatile false
    end

    megatiles do
      new_megatiles = single_megatile ? [Factory.create(:megatile, owner: owner, world: owner.world)] : []
    end

  end
end
