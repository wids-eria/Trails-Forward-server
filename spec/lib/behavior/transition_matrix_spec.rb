require 'spec_helper'

FECUNDITY0 = 0
FECUNDITY1 = 1.49
SURVIVAL0 = 0.48
SURVIVAL1 = 0.68

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

  its(:litter_size_probabilities) { should == [FECUNDITY0,
                                               FECUNDITY1] }

  context 'mortality' do
    before do
      daily_mortality = 1 - daily_prob("SURVIVAL#{life_state}".constantize)
      agent.life_state = life_state
      agent.stubs(:rand).returns(should_happen ? daily_mortality - 0.05 : daily_mortality + 0.05)
    end

    context 'juvenile' do
      let(:life_state) { 0 }

      context 'given they pass transition probability' do
        let(:should_happen) { false }

        it 'does not die' do
          agent.should_not be_die
        end
      end

      context 'given they fail the transition probability' do
        let(:should_happen) { true }

        it 'dies' do
          agent.should be_die
        end
      end
    end

    context 'adult' do
      let(:life_state) { 1 }

      context 'given they pass transition probability' do
        let(:should_happen) { false }

        it 'does not die' do
          agent.should_not be_die
        end
      end

      context 'given they fail the transition probability' do
        let(:should_happen) { true }

        it 'dies' do
          agent.should be_die
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

      context 'juvenile' do
        let(:litter_probability) { FECUNDITY0.divmod 1 }
        let(:life_state) { 0 }

        before do
          agent.stubs(:rand).returns(small_litter ? [litter_probability[1] + 0.05, 1].min : [litter_probability[1] - 0.05, 0].max)
        end

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

        before do
          agent.stubs(:rand).returns(small_litter ? [litter_probability[1] + 0.05, 1].min : [litter_probability[1] - 0.05, 0].max)
        end

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

      describe 'reproduce?' do
        let(:life_state) { 1 }
        before do
          agent.age = age
        end

        subject { agent.reproduce? }

        context 'less than a year' do
          let(:age) { 350 }
          it { should_not be }
        end

        context 'at one year' do
          let(:age) { 364 }
          it { should be }
        end

        context 'at more than a year, less than two' do
          let(:age) { 370 }
          it { should_not be }
        end

        context 'at two years' do
          let(:age) { 729 }
          it { should be }
        end
      end
    end
  end

  describe '#life_state' do
    subject { agent.life_state }

    before do
      agent.stubs(:reproduce?)
    end

    context 'new agent' do
      it { should == 0 }
    end

    describe 'transition' do
      before do
        agent.life_state = 0
        agent.age = age
        agent.tick
      end

      context 'less than a year' do
        let(:age) { 350 }
        it { should == 0 }
      end

      context 'at one year' do
        let(:age) { 365 }
        it { should == 1 }
      end

      context 'at more than a year' do
        let(:age) { 370 }
        it { should == 1 }
      end
    end
  end

end
