require 'spec_helper'

class SensingAgent < Agent
  max_view_distance 4
end

describe Agent do
  its(:max_view_distance) { should == 0 }
end
describe SensingAgent do
  its(:max_view_distance) { should == 4 }
end
