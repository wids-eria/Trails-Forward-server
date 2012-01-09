require 'spec_helper'

class FecundityAgent < Agent
  fecundity 1.72

  def go
  end
end

describe Agent do
  its(:fecundity) { should == 0 }
end

describe FecundityAgent do
  its(:fecundity) { should == 1.72 }
end
