require 'spec_helper'

describe Tribble do
  let(:world) { create(:world_with_properties) }
  let(:agent) { create(:tribble, world: world) }
  subject { agent }

  describe '#go' do
    after { agent.go }

    context 'given it should move' do
      before do
        agent.stubs(:should_die => false)
        agent.stubs(:should_move? => true)
        agent.stubs(:fidgit? => false)
      end
      it('moves') { agent.expects(:try_move).returns(true) }
    end

    context 'given it should not move' do
      before { agent.stubs(:should_move? => false) }
      it('does not move') { agent.expects(:try_move).never }
    end
  end

  describe "#should_move?" do
    let(:move_threshold) { 4 }
    let(:peers) { peer_count.times.collect { build :tribble } }
    subject { agent.should_move? }
    before do
      Tribble.any_instance.stubs(:nearby_peers => peers,
                                :move_threshold => move_threshold)
    end

    context "with less neighbors than the move threshold" do
      let(:peer_count) { move_threshold - 1 }
      before { agent.stubs(rand: 1.0) }
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
      agent.expects(:nearby_tile_preference_vectors).returns(land_prefs)
      agent.expects(:nearby_agent_preference_vectors).returns(agent_prefs)
    end
    subject { agent.most_desirable_heading }
    it { should == Vector[1,1] }
  end


end
