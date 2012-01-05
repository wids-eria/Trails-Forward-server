require 'spec_helper'

FECUNDITY0 = 0
FECUNDITY1 = 1.49
SURVIVAL0 = 0.48
SURVIVAL1 = 0.48

def daily_prob prob
  prob ** (1.0/365)
end


class TransitionMatrixAgent < Agent
  include Behavior::TransitionMatrix
  transition_matrix [[FECUNDITY0, FECUNDITY1],
                     [SURVIVAL0,  SURVIVAL1 ]]
end

describe TransitionMatrixAgent do
  let(:agent) { TransitionMatrixAgent.new }
  subject { agent }

  its(:daily_survival_probabilities) { should == [daily_prob(SURVIVAL0),
                                                  daily_prob(SURVIVAL1)] }

  its(:litter_size_probabilities) { should == [FECUNDITY0.divmod(1),
                                               FECUNDITY1.divmod(1)] }

  context 'mortality' do
    before do
      daily_survival = daily_prob("SURVIVAL#{life_state}".constantize)
      agent.life_state = life_state
      agent.stub(:rand).and_return(should_happen ? daily_survival - 0.05 : daily_survival + 0.05)
    end

    context 'juvenile' do
      let(:life_state) { 0 }

      context 'given they pass transition probability' do
        let(:should_happen) { true }

        it 'does not die' do
          agent.should_receive(:die!).never
          agent.try_survival!
        end
      end

      context 'given they fail the transition probability' do
        let(:should_happen) { false }

        it 'dies' do
          agent.should_receive(:die!).and_return(true)
          agent.try_survival!
        end
      end
    end

    context 'adult' do
      let(:life_state) { 1 }

      context 'given they pass transition probability' do
        let(:should_happen) { true }

        it 'does not die' do
          agent.should_receive(:die!).never
          agent.try_survival!
        end
      end

      context 'given they fail the transition probability' do
        let(:should_happen) { false }

        it 'dies' do
          agent.should_receive(:die!).and_return(true)
          agent.try_survival!
        end
      end
    end
  end

  context 'reproduction' do

    before do
      agent.life_state = life_state
    end

    describe '#litter_size' do
      subject { agent.litter_size }

      before do
        agent.stub(:rand).and_return(small_litter ? [litter_probability[1] + 0.05, 1].min : [litter_probability[1] - 0.05, 0].max)
      end

      context 'juvenile' do
        let(:litter_probability) { FECUNDITY0.divmod 1 }
        let(:life_state) { 0 }

        context 'small litter size' do
          let(:small_litter) { true }
          it 'returns the floor of the fecundity' do
            subject.should == litter_probability[0]
          end
        end

        context 'large litter size' do
          let(:small_litter) { false }
          it 'returns the ceiling of the fecundity' do
            subject.should == litter_probability[0]
          end
        end
      end

      context 'adult' do
        let(:life_state) { 1 }
        let(:litter_probability) { FECUNDITY1.divmod 1 }

        context 'small litter size' do
          let(:small_litter) { true }
          it 'returns the floor of the fecundity' do
            subject.should == litter_probability[0]
          end
        end

        context 'large litter size' do
          let(:small_litter) { false }
          it 'returns the ceiling of the fecundity' do
            subject.should == litter_probability[0] + 1
          end
        end
      end
    end
  end

  describe '#life_state' do
    context 'new agent' do
      its(:life_state) { should == 0 }
    end

    xit 'transition' do
      before do
        agent.life_state = life_state
        agent.stub(:rand).and_return(should_happen ? 0 : 1)
        agent.try_transition!
      end

      context 'given they pass transition probability' do
        let(:should_happen) { true }
        its(:life_state) { should == 1 }
      end

      context 'given they fail the transition probability' do
        let(:should_happen) { false }
        its(:life_state) { should == 0 }
      end
    end
  end

end
