require 'spec_helper'

class HabitatSuitabilityAgent < Agent
  include Behavior::HabitatSuitability
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

  describe '#suitability_survival_modifier' do
    before do
      agent.stub_chain(:resource_tile, land_cover_type: ResourceTile.cover_type_number(cover_code))
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
    let(:tile) { ResourceTile.new land_cover_type: cover_code }
    subject { agent.tile_utility tile }

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

  describe '#suitability_fecundity_modifier' do
    before do
      agent.stub_chain(:resource_tile, land_cover_type: ResourceTile.cover_type_number(cover_code))
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
end
