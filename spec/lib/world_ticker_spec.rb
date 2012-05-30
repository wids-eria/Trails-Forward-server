require 'spec_helper'

describe WorldTicker do
  let(:world_ticker) { WorldTicker.new world: world }
  let(:player1) { create :lumberjack }
  let(:player2) { create :conserver }
  let(:player3) { create :developer }
  let(:world) { create :world, players: [player1, player2, player3] }

  it 'allows a turn if all players are ready' do
    world.current_turn = 5
    player1.last_turn_played = 4
    player2.last_turn_played = 4
    player3.last_turn_played = 4
    world_ticker.can_process_turn?.should == true
  end

  it 'doesnt allow a turn if all players are ready' do
    world.current_turn = 5
    player1.last_turn_played = 3
    player2.last_turn_played = 4
    player3.last_turn_played = 4
    world_ticker.can_process_turn?.should == false
  end
end
