require 'spec_helper'

class HabitatSuitabilityAgent < Agent
  include Behavior::HabitatSuitability
  habitat_suitability open_water: 0,
                      dwarf_scrub: 10,
                      shrub_scrub: 8.7

  habitat_survival_modifier do |suitability_rating|
    (1 - (1 - (suitability_rating / 10.0) ** 3))
  end

  def go
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

  describe '#habitat_survival_modifier' do
    before do
      agent.stub_chain(:resource_tile, land_cover_type: ResourceTile.cover_type_number(cover_code))
    end
    subject { agent.habitat_survival_modifier }
    context 'For a 0 suitability environment' do
      let(:cover_code) { :open_water }
      it { should == 0 }
    end
    context 'For a 10 suitability environment' do
      let(:cover_code) { :dwarf_scrub }
      it { should == 1 }
    end
  end
end
