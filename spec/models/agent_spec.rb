require 'spec_helper'

describe Agent do
  it { should belong_to :resource_tile }
  it { should belong_to :world }
end
