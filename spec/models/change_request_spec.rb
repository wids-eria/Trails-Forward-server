require 'spec_helper'

describe ChangeRequest do
  it { should belong_to :target }
  it { should belong_to :world }

  it { should validate_presence_of :target } 
  it { should validate_presence_of :world_id }
  it { should validate_numericality_of :world_id }
end
