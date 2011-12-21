require 'spec_helper'

describe Agent do
  it { should belong_to :resource_tile }
  it { should belong_to :world }
  it { should have_db_column(:heading).of_type(:integer) }

  let(:world) { create(:world_with_tiles) }
  let(:agent) { build(:generic_agent, world: world) }

  describe 'scope: ' do
    describe '.for_types (or .for_type alias' do
      let!(:tribble) { create :tribble, world: world }
      let!(:generic) { create :generic_agent, world: world }

      context 'passed a single type' do
        it 'returns agents of that type' do
          Agent.for_types([:tribble]).should == [tribble]
        end
        it 'has for_type convenience alias' do
          Agent.for_type(:tribble).should == [tribble]
        end
      end
      context 'passed multiple types' do
        it 'returns agents of those types' do
          Agent.for_types([:tribble, :generic_agent]).to_set.should == [tribble, generic].to_set
        end
      end
      context 'passed no types' do
        it 'returns no agents' do
          Agent.for_types([]).should be_empty
        end
      end
    end
  end

  describe '#tick' do
    let(:agent) { create :generic_agent, age: 0 }
    before { agent.stub(go: true) }

    it 'advances agent age' do
      agent.tick
      agent.age.should == 1
    end

    it 'calls the #go hook' do
      agent.should_receive(:go).and_return(true)
      agent.tick
    end
  end

  describe '#location=' do
    context 'on an existing record' do
      before do
        agent.save
        agent.location = [4.4, 5.5]
      end

      it 'assigns coords to x and y' do
        agent.x.should == 4.4
        agent.y.should == 5.5
      end

      it 'assigns geometry point' do
        agent.geom.x.should == 4.4
        agent.geom.y.should == 5.5
      end
    end

    context 'on a new record' do
      before do
        agent.location = [4.4, 5.5]
        agent.save
      end

      it 'assigns coords to x and y' do
        agent.x.should == 4.4
        agent.y.should == 5.5
      end

      it 'assigns geometry point' do
        agent.geom.x.should == 4.4
        agent.geom.y.should == 5.5
      end
    end
  end

  describe '#location' do
    it 'returns array of [x,y] values' do
      agent = build(:generic_agent, x: 1.5, y:3.7)
      agent.location.should == [1.5, 3.7]
    end
  end

  context 'multiple agents on one resource tile' do
    let(:world) { create :world_with_tiles }
    let(:agent1) { create :generic_agent, world: world, location: location1 }
    let(:agent2) { create :generic_agent, world: world, location: location2 }
    let(:location1) { [0.5, 0.5] }
    context 'different actual coordinates' do
      let(:location2) { [0.6, 0.4] }
      example 'agent 1 is valid' do
        agent1.should be_valid
      end
      example 'agent 2 is valid' do
        agent2.should be_valid
      end
      example 'agent 1 and agent 2 share the tile' do
        agent1.resource_tile.should == agent2.resource_tile
      end
    end

    context 'exactly the same position' do
      let(:location2) { [0.5, 0.5] }
      example 'agent 1 is valid' do
        agent1.should be_valid
      end
      example 'agent 2 is valid' do
        agent2.should be_valid
      end
      example 'agent 1 and agent 2 share the tile' do
        agent1.resource_tile.should == agent2.resource_tile
      end
      example 'agent 1 and agent 2 have the same location' do
        agent1.location.should == agent2.location
      end
    end
  end

  describe '#nearby_agents' do
    let(:world) { create :world_with_tiles }
    let!(:agent1) { create :generic_agent, world: world, location: location1 }
    let!(:agent2) { create :generic_agent, world: world, location: location2 }
    let!(:tribble) { create :tribble, world: world, location: location1 }
    let(:location1) { [0.5, 0.5] }
    context 'near enough to see' do
      let(:location2) { [0.6, 0.4] }
      example 'agent 1 can see agent 2' do
        agent1.nearby_agents(radius: 1).to_set.should == [tribble, agent2].to_set
      end
    end
    context 'too far away' do
      let(:location2) { [2.6, 2.4] }
      example 'agent 1 can not see agent 2' do
        agent1.nearby_agents(radius: 1).should == [tribble]
      end
    end
    context 'farther than max view distance' do
      let(:location2) { [2.6, 2.4] }
      before { GenericAgent.any_instance.stub(max_view_distance: 2) }
      example 'agent 1 can not see agent 2' do
        agent1.nearby_agents(radius: 10).should == [tribble]
      end
    end
    context 'requesting specific agent type' do
      let(:location2) { [0.6, 0.4] }
      example 'agent 1 can request to only see tribbles' do
        agent1.nearby_agents(types: [:tribble], radius: 1).should == [tribble]
      end
      example 'agent 1 can request to only see agents' do
        agent1.nearby_agents(types: [:generic_agent], radius: 1).should == [agent2]
      end
      example 'agent 1 can request to see agents and tribbles' do
        agent1.nearby_agents(types: [:generic_agent, :tribble], radius: 1).to_set.should == [agent2, tribble].to_set
      end
    end
  end

  describe '#nearby_peers' do
    let(:world) { create :world_with_tiles }
    let!(:agent1) { create :generic_agent, world: world, location: location1 }
    let!(:tribble1) { create :tribble, world: world, location: location1 }
    let!(:tribble2) { create :tribble, world: world, location: location1 }
    let(:location1) { [0.5, 0.5] }

    example 'only returns agents of same type' do
      tribble1.nearby_peers(radius: 1).should == [tribble2]
    end
  end

  describe '#nearby_tiles' do
    let(:world) { create :world_with_tiles }
    let!(:agent) { create :generic_agent, world: world, location: location }
    let(:location) { [3.5, 3.5] }

    example 'radius 1' do
      agent.nearby_tiles(radius: 1).map(&:location).to_set.should == [[2,3], [3,2], [3,3], [3,4], [4,3]].to_set
    end

    example 'radius 1.5' do
      agent.nearby_tiles(radius: 1.5).map(&:location).to_set.should == [[2,2], [2,3], [2,4], [3,2], [3,3], [3,4], [4,2], [4,3], [4,4]].to_set
    end

    example 'radius 2' do
      agent.nearby_tiles(radius: 2).map(&:location).to_set.should == [[1,3], [2,2], [2,3], [2,4], [3,1], [3,2], [3,3], [3,4], [3,5], [4,2], [4,3], [4,4], [5,3]].to_set
    end
  end

  describe '#move' do
    let(:world) { create :world_with_tiles }
    let(:agent) { build(:generic_agent, world: world, location: location, heading: heading) }
    subject { agent }
    before do
      agent.move(distance)
    end

    context 'starting at location [1, 1]' do
      let(:location) { [1, 1] }

      context 'with heading 45' do
        let(:heading) { 45 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [1.71, 1.71] }
        end
      end

      context 'with heading 0' do
        let(:heading) { 0 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [1.0, 2.0] }

          it 'changes associated resource tile' do
            agent.resource_tile.location.should == [1, 2]
          end
        end

        context 'passed a distance of -1' do
          let(:distance) { -1 }
          its(:location) { should == [1, 0] }
        end

        context 'passed a distance of -2' do
          let(:distance) { -2 }
          its(:location) { should == [1, 0] }
        end
      end

      context 'with heading 90' do
        let(:heading) { 90 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [2, 1] }
        end

        context 'passed a distance of -1' do
          let(:distance) { -1 }
          its(:location) { should == [0, 1] }
        end
      end

    end

    context 'starting at location [5.5, 3.7]' do
      let(:location) { [5.5, 3.7] }

      context 'with heading 0' do
        let(:heading) { 0 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [5.5, 4.7] }
        end

        context 'passed a distance of -1' do
          let(:distance) { -1 }
          its(:location) { should == [5.5, 2.7] }
        end
      end

      context 'with heading 180' do
        let(:heading) { 180 }

        context 'passed a distance of 3.4' do
          let(:distance) { 3.4 }
          its(:location) { should == [5.5, 0.3] }
        end
      end

    end

  end

  describe '#calculate_offset_coordinates' do
    subject { Agent.calculate_offset_coordinates(heading, distance) }

    context 'with heading 45' do
      let(:heading) { 45 }

      context 'passed a distance of 1' do
        let(:distance) { 1 }
        it { should == [0.71, 0.71] }
      end
    end
  end
end
