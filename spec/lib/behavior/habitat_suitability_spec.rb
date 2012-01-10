require 'spec_helper'

class HabitatSuitabilityAgent < Agent
  include Behavior::HabitatSuitability
  survival_rate 0.8
  max_view_distance 1

  habitat_suitability open_water: 0,
                      dwarf_scrub: 10,
                      shrub_scrub: 8.7,
                      pasture_hay: 5

  suitability_survival_modifier do |suitability_rating|
    1 - (1 - suitability_rating / 10.0) ** 3
  end

  suitability_fecundity_modifier do |suitability_rating|
    suitability_rating / 10.0
  end

  tile_utility do |agent, tile|
    agent.suitability_survival_modifier_for tile
  end
end

describe HabitatSuitabilityAgent do
  let(:agent) { HabitatSuitabilityAgent.new }
  describe '#habitat_suitability' do
    subject { agent.habitat_suitability cover_code }
    context 'for an unspecified habitat' do
      let(:cover_code) { ResourceTile.cover_type_number(:barren) }
      it { should == 5.0 }
    end
    context 'for a specified habitat' do
      let(:cover_code) { ResourceTile.cover_type_number(:shrub_scrub) }
      it { should == 8.7 }
    end
    context 'for a habitat symbol' do
      let(:cover_code) { :dwarf_scrub }
      it { should == 10 }
    end
  end

  # describe '#yearly_survival_rate' do
  #   let(:tile) { ResourceTile.new landcover_class_code: ResourceTile.cover_type_number(cover_code) }
  #   subject { agent.yearly_survival_rate }
  #   before do
  #     agent.resource_tile = tile
  #   end

  #   context 'for a deadly environment' do
  #     let(:cover_code) { :open_water }
  #     it { should == 1 }
  #   end
  #   context 'for a perfect environment' do
  #     let(:cover_code) { :dwarf_scrub }
  #     it { should == 0.8 }
  #   end
  # end

  describe '#suitability_survival_modifier' do
    before do
      agent.stub(:resource_tile).and_return(stub 'resource_tile', landcover_class_code: ResourceTile.cover_type_number(cover_code))
    end
    subject { agent.suitability_survival_modifier }

    context 'for a non-suitable environment' do
      let(:cover_code) { :open_water }
      it { should be_kind_of(Float) }
      it { should == 0.0 }
    end

    context 'for an integer defined suitability environment' do
      let(:cover_code) { :pasture_hay }
      it { should be_kind_of(Float) }
      it { should == 0.875 }
    end

    context 'for an float defined suitability environment' do
      let(:cover_code) { :shrub_scrub }
      it { should be_kind_of(Float) }
      it { should == 0.997803 }
    end

    context 'for a perfectly suitabile environment' do
      let(:cover_code) { :dwarf_scrub }
      it { should be_kind_of(Float) }
      it { should == 1.0 }
    end
  end

  describe '#tile_utility' do
    let(:tile) { build :resource_tile, landcover_class_code: ResourceTile.cover_type_number(cover_code) }
    subject { agent.tile_utility tile }

    context 'for a non-suitable environment' do
      let(:cover_code) { :open_water }
      it { tile.landcover_class_code.should == 11 }
      it { should be_kind_of(Float) }
      it { should == 0.0 }
    end

    context 'for an integer defined suitability environment' do
      let(:cover_code) { :pasture_hay }
      it { should be_kind_of(Float) }
      it { should == 0.875 }
    end

    context 'for an float defined suitability environment' do
      let(:cover_code) { :shrub_scrub }
      it { should be_kind_of(Float) }
      it { should == 0.997803 }
    end

    context 'for a perfectly suitabile environment' do
      let(:cover_code) { :dwarf_scrub }
      it { should be_kind_of(Float) }
      it { should == 1.0 }
    end
  end

  describe '#suitability_fecundity_modifier' do
    before do
      agent.stub(:resource_tile).and_return(stub 'resource_tile', landcover_class_code: ResourceTile.cover_type_number(cover_code))
    end
    subject { agent.suitability_fecundity_modifier }

    context 'for a non-suitable environment' do
      let(:cover_code) { :open_water }
      it { should be_kind_of(Float) }
      it { should == 0.0 }
    end

    context 'for an integer defined suitability environment' do
      let(:cover_code) { :pasture_hay }
      it { should be_kind_of(Float) }
      it { should == 0.5 }
    end

    context 'for an float defined suitability environment' do
      let(:cover_code) { :shrub_scrub }
      it { should be_kind_of(Float) }
      it { should be_within(0.000001).of(0.87) }
    end

    context 'for a perfectly suitabile environment' do
      let(:cover_code) { :dwarf_scrub }
      it { should be_kind_of(Float) }
      it { should == 1.0 }
    end
  end

  describe '#best_nearby_tile' do
    let(:world) { create :world_with_tiles, width: 3, height: 3}
    before do
      [[:barren, :barren, :barren],
       [:barren, :barren, :dwarf_scrub],
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
