FactoryGirl.define do
  factory :megatile_grouping do
    ignore do
      owner nil
      single_megatile false
    end

    megatiles do
      # these factories are too interdependent, causing stray worlds.
      if owner.present?
        new_megatiles = single_megatile ? [FactoryGirl.create(:megatile, owner: owner, world: owner.world)] : []
      else
        new_megatiles = single_megatile ? [FactoryGirl.create(:megatile, owner: owner)] : []
      end
    end

  end
end
