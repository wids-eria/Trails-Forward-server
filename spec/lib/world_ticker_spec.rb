require 'spec_helper'

describe WorldTicker do
  let(:world_ticker) { WorldTicker.new world: world }
  let(:player1) { create :lumberjack }
  let(:player2) { create :conserver  }
  let(:player3) { create :developer  }
  let(:world)   { create :world, players: [player1, player2, player3] }

  before do
    world_ticker.turn_duration = 30.minutes
  end

  context 'when time not elapsed' do
    let(:now) { DateTime.now }

    before do
      world.turn_started_at = now - 5.minutes

      player1.last_turn_played_at = DateTime.now - 1.minute
      player2.last_turn_played_at = DateTime.now - 1.minute
      player3.last_turn_played_at = DateTime.now - 1.minute
    end

    describe '#can_process_turn?' do
      it 'allows a turn if all players are ready' do
        world.current_turn = 5
        player1.last_turn_played = 5
        player2.last_turn_played = 5
        player3.last_turn_played = 5

        world_ticker.can_process_turn?.should == true
      end

      it 'doesnt allow a turn if all players are not ready' do
        player1.last_turn_played_at = world.turn_started_at - 1.minute
        player2.last_turn_played_at = world.turn_started_at + 1.minute
        player3.last_turn_played_at = world.turn_started_at + 2.minutes

        world.current_turn = 5
        player1.last_turn_played = 4
        player2.last_turn_played = 5
        player3.last_turn_played = 5

        world_ticker.can_process_turn?.should == false
      end
    end

    describe '#time_left' do
      let(:time_left) { world_ticker.time_left }
      it 'returns seconds until turn end' do
        time_left.should == 1500
        time_left.should be_an(Integer)
      end
    end
  end

  context 'when time elapsed' do
    before do
      world.turn_started_at = DateTime.now - 1.hour
    end
    describe '#can_process_turn?' do
      it 'allows a turn if not all players are ready' do
        player1.last_turn_played_at = world.turn_started_at - 1.hour
        player2.last_turn_played_at = world.turn_started_at - 1.hour
        player3.last_turn_played_at = world.turn_started_at - 1.minute

        world.current_turn = 5
        player1.last_turn_played = 4
        player2.last_turn_played = 5
        player3.last_turn_played = 5

        world_ticker.can_process_turn?.should == true
      end
    end

    describe '#time_left' do
      it 'returns seconds since turn ended' do
        world_ticker.time_left.should == -1800
      end
    end
  end

  describe '#turn' do
    it "turns" do
      world_ticker.turn
    end

    it 'transfers money to players'
    it 'grows trees'
    it 'calculates marten suitability'
    it 'calculates housing suitability'
  end
end
