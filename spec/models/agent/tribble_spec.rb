require 'spec_helper'

describe Tribble do
  let(:world) { create(:world_with_properties) }
  let(:agent) { create(:tribble, world: world) }
  subject { agent }

  describe '#go' do
    after { agent.go }

    context 'given it should move' do
      before do
        agent.stub(:should_die => false)
        agent.stub(:should_move? => true)
        agent.stub(:fidgit? => false)
      end
      it('moves') { agent.should_receive(:move).and_return(true) }
    end

    context 'given it should not move' do
      before { agent.stub(:should_move? => false) }
      it('does not move') { agent.should_not_receive(:move).and_return(true) }
    end
  end

  describe "#should_move?" do
    let(:move_threshold) { 4 }
    let(:peers) { peer_count.times.collect { build :tribble } }
    subject { agent.should_move? }
    before do
      Tribble.any_instance.stub(:nearby_peers => peers,
                                :move_threshold => move_threshold)
    end

    context "with less neighbors than the move threshold" do
      let(:peer_count) { move_threshold - 1 }
      before { agent.stub(rand: 1.0) }
      it { should == false }
    end

    context "with more neighbors than the move threshold" do
      let(:peer_count) { move_threshold + 1 }
      it { should == true }
    end
  end

  describe '#most_desirable_heading' do
    let(:land_prefs) { [Vector[3,4]] }
    let(:agent_prefs) { [Vector[-2, -3]] }
    before do
      agent.should_receive(:nearby_tile_preference_vectors).and_return(land_prefs)
      agent.should_receive(:nearby_agent_preference_vectors).and_return(agent_prefs)
    end
    subject { agent.most_desirable_heading }
    it { should == Vector[1,1] }
  end

  xit '#agent_pref_vector' do
    let(:x) { agent.location[0] }
    let(:y) { agent.location[1] }
    let(:agent) { build :tribble, location: [1.4, 3.2] }
    let(:other_agent) { build :tribble, location: [x + 2, y + 1] }

    before do
      agent.should_receive(:nearby_agents).and_return([other_agent])
    end

    subject { agent.agent_pref_vector(other_agent).clean }
    it do
      should == [Vector[2,1]]
    end
  end

end
