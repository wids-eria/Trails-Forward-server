require 'spec_helper'

describe ConstructionChangeRequest do
  it "has list of allowed targets" do
      change_request = ConstructionChangeRequest.new target: Megatile.new
      change_request.valid?

      change_request.errors[:target].should be_empty
  end

  it "should be invalid if target not allowed" do
      change_request = ConstructionChangeRequest.new target: WaterTile.new
      change_request.valid?

      change_request.errors[:target].should_not be_empty
  end
end
