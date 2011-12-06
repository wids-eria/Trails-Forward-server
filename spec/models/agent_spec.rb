require 'spec_helper'

describe Agent do
  it { should belong_to :resource_tile }
  it { should belong_to :world }
  it { should have_db_column(:heading).of_type(:integer) }

  let(:agent) { build(:agent) }

  describe 'x' do
    it 'defaults to nil' do
      agent.x.should be_nil
    end
  end

  describe 'y' do
    it 'defaults to nil' do
      agent.y.should be_nil
    end
  end

  describe '#location=' do
    it 'assigns coords to x and y' do
      agent.location = [4.4, 5.5]
      agent.x.should == 4.4
      agent.y.should == 5.5
    end
  end

  describe '#location' do
    it 'returns array of [x,y] values' do
      agent = build(:agent, x: 1.5, y:3.7)
      agent.location.should == [1.5, 3.7]
    end
  end

  context 'multiple agents on one resource tile' do
    let(:world) { create :world_with_tiles }
    let(:agent1) { create :agent, :world => world, :location => location1 }
    let(:agent2) { create :agent, :world => world, :location => location2 }
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

  context 'multiple agents in proximity can see each other' do
    let(:world) { create :world_with_tiles }
    let(:agent1) { create :agent, :world => world, :location => location1 }
    let(:agent2) { create :agent, :world => world, :location => location2 }
    let(:location1) { [0.5, 0.5] }
    context 'near enough to see' do
      let(:location2) { [0.6, 0.4] }
      example 'agent 1 can see agent 2' do
        agent1.nearby_agents(radius: 1).should == [agent2]
      end
    end
    context 'too far away' do
      let(:location2) { [2.6, 2.4] }
      example 'agent 1 can not see agent 2' do
        agent1.nearby_agents(radius: 1).should == []
      end
    end
    context 'farther than max view distance' do
      let(:location2) { [2.6, 2.4] }
      before { Agent.any_instance.stub(:max_view_distance, 2) }
      example 'agent 1 can not see agent 2' do
        agent1.nearby_agents(radius: 10).should == []
      end
    end
  end

  describe '#move' do
    let(:world) { create :world_with_tiles }
    let(:agent) { build(:agent, world: world, location: location, heading: heading) }
    subject { agent }
    before do
      agent.move(distance)
    end

    context 'starting at location [0, 0]' do
      let(:location) { [0, 0] }

      context 'with heading 45' do
        let(:heading) { 45 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [0.71, 0.71] }
        end
      end

      context 'with heading 0' do
        let(:heading) { 0 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [0.0, 1.0] }

          it 'changes associated resource tile' do
            new_tile = agent.resource_tile
            new_tile.location.should == [0, 1]
          end
        end

        context 'passed a distance of -1' do
          let(:distance) { -1 }
          its(:location) { should == [0, -1] }
        end
      end

      context 'with heading 90' do
        let(:heading) { 90 }

        context 'passed a distance of 1' do
          let(:distance) { 1 }
          its(:location) { should == [1, 0] }
        end

        context 'passed a distance of -1' do
          let(:distance) { -1 }
          its(:location) { should == [-1, 0] }
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
