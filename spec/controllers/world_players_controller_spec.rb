require 'spec_helper'

describe WorldPlayersController do
  include Devise::TestHelpers
  render_views

  let(:world)  { create :world, turn_started_at: DateTime.now - 5.minutes, current_turn: 5 }
  let(:user)   { player.user }
  let(:player) { create :lumberjack, world: world, last_turn_played: 4 }
  let(:json)   { JSON.parse(response.body) }

  before do
    sign_in user
  end

  describe '#submit_turn' do
    it 'sets players turn to current world' do
      put :submit_turn, world_id: world.id, format: 'json'
      player.reload.last_turn_played.should == 5
    end
  end
    
  describe '#destroy' do
    let(:user) { player.user }
    let(:player) { create :lumberjack }
    let(:other_player) { create :developer }
    let(:other_user) { other_player.user }
    let(:user_to_sign_in) { other_user }
    
    before do
      sign_in user_to_sign_in
    end
    
    context 'destroying a player as god' do
      it 'should destroy a player object' do
        player_id = player.id
        delete :destroy, world_id: player.world.id, id: player.id, god_mode: 'iddqd'
        Player.where(:id => player_id).length.should == 0
      end
    end
  end  #destroy
end
