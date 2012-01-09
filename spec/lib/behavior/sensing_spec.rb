require 'spec_helper'

class SensingAgent < Agent
  max_view_distance 4
  tile_utility do |tile|
    0.7
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
end

describe SensingAgent do
  let(:agent) { SensingAgent.new }
  its(:max_view_distance) { should == 4 }

  describe '#tile_utility' do
    it 'overrides the default' do
      agent.tile_utility(ResourceTile.new).should == 0.7
    end
  end
end
