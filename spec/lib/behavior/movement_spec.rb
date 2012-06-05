require 'spec_helper'

class MovingAgent < Agent
  move_when do
    true
  end

  move_to do |agent|
    agent.location.map {|x| x + 1}
  end
end

describe Agent do
  it { should_not be_move }
end

describe MovingAgent do
  let(:agent) { MovingAgent.new x: 0, y: 0 }
  subject { agent }

  #it { should be_move }
  describe '#move' do
    before do
      agent.stubs(:world => stub('resource_tile_at', :resource_tile_at => ResourceTile.new(x: agent.x.floor, y: agent.y.floor)))
      agent.move
    end

    its(:location) { should == [1, 1] }
  end
  
  describe '#walk_forward' do 
    let(:agent) { build :agent}
    before do
      agent.walk_forward 1
    end
    
    its(:location) { should == [1, 2]}
  end

  describe '#walk_forward 90 degree heading' do 
    let(:agent) { build :agent}
    before do
      agent.heading = 90
      agent.walk_forward 1
    end
    
    its(:location) { should == [2, 1]}
  end
end
