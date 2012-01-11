require 'spec_helper'

describe Agent do
  let(:agent) { Agent.new }
  subject { agent }
  its(:daily_survival_rate) { should == 1 }
  its(:annual_survival_rate) { should == 1 }
  its(:daily_mortality_rate) { should == 0 }
  its(:annual_mortality_rate) { should == 0 }
end

class SurvivalAgent < Agent
  annual_survival_rate 0.8
end

describe SurvivalAgent do
  let(:agent) { SurvivalAgent.new }
  subject { agent }
  its(:daily_survival_rate) { should == 0.8 ** (1/365.0) }
  its(:annual_survival_rate) { should == 0.8 }
  its(:daily_mortality_rate) { should == 1 - agent.daily_survival_rate }
  its(:annual_mortality_rate) { should be_within(1.0e-08).of(0.2) }
end

class MortalityAgent < Agent
  annual_mortality_rate 0.12
end

describe MortalityAgent do
  let(:agent) { MortalityAgent.new }
  subject { agent }
  its(:daily_survival_rate) { should == 0.88 ** (1/365.0) }
end
