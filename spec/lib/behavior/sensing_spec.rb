require 'spec_helper'

class SensingAgent < Agent
  include Behavior::HabitatSuitability
  max_view_distance 4

  habitat_suitability barren: 0,
                      coniferous: 4,
                      cultivated_crops: 5,
                      deciduous: 8.5

  tile_utility do |agent, tile|
    agent.suitability_survival_modifier_for(tile)
  end

  suitability_survival_modifier 0.7 do |suitability_rating|
    suitability_rating / 10.0
  end
end

describe Agent do
  let(:agent) { Agent.new }
  its(:max_view_distance) { should == 0 }

  describe '#tile_utility' do
    it 'defaults to 0.5' do
      agent.tile_utility(ResourceTile.new).should == 0.5
    end
  end
  
  describe '#patch_ahead' do
    let!(:agent) { create :agent, world: world}
    let!(:world) { create :world_with_tiles }

    it 'can see whats in front of its face' do
      agent.patch_ahead.y.should == 2
    end
  end
end

describe SensingAgent do
  let(:agent) { SensingAgent.new }
  its(:max_view_distance) { should == 4 }

  describe '#tile_utility' do
    it 'overrides the default' do
      agent.tile_utility(ResourceTile.new).should == 0.7
    end
  end

  describe '#best_nearby_tile' do
    let(:world) { create :world_with_tiles, width: 3, height: 3}
    before do
      [[:barren, :barren, :barren],
       [:barren, :barren, :deciduous],
       [:barren, :barren, :barren]].each_with_index do |row, y|
        row.each_with_index do |val, x|
          tile = world.resource_tile_at(x,y)
          cover_code = ResourceTile.cover_type_number(val)
          tile.update_attributes(landcover_class_code: cover_code)
        end
      end
      agent.update_attributes(world: world, location: world.resource_tile_at(1,1).center_location)
    end

    example 'returns the tile with the highest utility' do
      agent.best_nearby_tile.should == world.resource_tile_at(2,1)
    end
  end
end
