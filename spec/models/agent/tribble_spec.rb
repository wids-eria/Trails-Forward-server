require 'spec_helper'

describe Tribble do
  let(:world) { create(:world_with_properties) }
  let(:agent) { create(:tribble, world: world) }
  subject { agent }

  describe '#tick' do
    after { agent.tick }

    context 'given it should move' do
      before do
        agent.stub(:should_die => false)
        agent.stub(:should_move? => true)
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

end
