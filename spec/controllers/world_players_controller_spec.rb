require 'spec_helper'

describe WorldPlayersController do
  include Devise::TestHelpers
  render_views

  let!(:user)     { player.user }
  let!(:player)   { create :lumberjack, last_turn_played: 4, world: world }
  let!(:player_2) { create :developer,  last_turn_played: 5, world: world }
  let!(:player_3) { create :conserver,  last_turn_played: 4, world: world }
  let!(:world)    { create :world, turn_started_at: DateTime.now, turn_state: 'playing', turn_started_at: DateTime.now - 4.minutes, current_turn: 5 }

  let(:json)     { JSON.parse(response.body) }

  before do
    sign_in user
  end

  describe '#submit_turn' do
    it 'sets players turn to current world' do
      put :submit_turn, world_id: world.id, format: 'json'
      player.reload.last_turn_played.should == 5
      world.reload.turn_state.should == "playing"
    end

    it 'marks world for processing if last player to submit' do
      player_3.last_turn_played = 5
      player_3.save!
      put :submit_turn, world_id: world.id, format: 'json'
      world.reload.turn_state.should == "ready_for_processing"
    end
  end
end
