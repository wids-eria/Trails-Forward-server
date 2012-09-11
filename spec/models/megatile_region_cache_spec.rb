require 'spec_helper'

describe MegatileRegionCache do

  context "when resource tiles are in a 2x2 cache" do
    let!(:world) { create :world }

    let!(:megatile_region_caches) do
      [
        create(:megatile_region_cache, world_id: world.id, x_min: 0, x_max: 1, y_min: 0, y_max: 1),
        create(:megatile_region_cache, world_id: world.id, x_min: 0, x_max: 1, y_min: 2, y_max: 3),
        create(:megatile_region_cache, world_id: world.id, x_min: 2, x_max: 3, y_min: 0, y_max: 1),
        create(:megatile_region_cache, world_id: world.id, x_min: 2, x_max: 3, y_min: 2, y_max: 3)
      ]
    end

    before do
      MegatileRegionCache.any_instance.stubs(json: [1,2,3].to_json)
    end

    it "queries a box containing 1 cache region" do
      data = MegatileRegionCache.megatiles_in_region(world.id, x_min: 0, x_max: 1, y_min: 0, y_max: 1)
      data[:json].should == [1,2,3].to_json
    end

    it "queries a strip containing 2 cache regions" do
      data = MegatileRegionCache.megatiles_in_region(world.id, x_min: 0, x_max: 3, y_min: 0, y_max: 1)
      data[:json].should == [1,2,3,1,2,3].to_json
    end

    it "queries a strip inside 2 cache regions" do
      data = MegatileRegionCache.megatiles_in_region(world.id, x_min: 0, x_max: 2, y_min: 0, y_max: 1)
      data[:json].should == [1,2,3,1,2,3].to_json
    end

    it "queries a box containing all 4 cache regions" do
      data = MegatileRegionCache.megatiles_in_region(world.id, x_min: 0, x_max: 4, y_min: 0, y_max: 4)
      data[:json].should == [1,2,3, 1,2,3, 1,2,3, 1,2,3].to_json
    end

    it "queries a box inside all 4 cache regions" do
      data = MegatileRegionCache.megatiles_in_region(world.id, x_min: 1, x_max: 2, y_min: 1, y_max: 2)
      data[:json].should == [1,2,3, 1,2,3, 1,2,3, 1,2,3].to_json
    end
  end
end
