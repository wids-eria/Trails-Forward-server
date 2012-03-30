require 'spec_helper'

describe Survey do
  it { should have_many :tile_surveys }

  context "when validating" do
    before { subject.valid? }

    it { should have(1).errors_on(:capture_date) }
  end

  it "wont recreate a tile data if it exists already in another survey of the same time period"
  it "has a time period"
end
