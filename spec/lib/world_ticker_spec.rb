require 'spec_helper'

describe WorldTicker do
  let(:world) { create :world }
  let(:world_ticker) { WorldTicker.new world: world }
  

  it 'should tick its world if all players are ready' do
  end
end
