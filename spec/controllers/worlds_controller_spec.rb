require 'spec_helper'

describe WorldsController do
  include Devise::TestHelpers
  render_views

  let(:world)  { create :world, turn_started_at: DateTime.now - 5.minutes, current_turn: 5 }
  let(:user)   { player.user }
  let(:player) { create :lumberjack, world: world, last_turn_played: 4 }
  let(:json)   { JSON.parse(response.body) }

  before do
    sign_in user
  end

  describe '#time_left_for_turn' do
    it 'returns time in seconds' do
      get :time_left_for_turn, id: world.id, format: 'json'
      response.should be_success
      json["time_left"].should be_within(2.0).of(1499)
    end
  end

  describe '#turn' do
    it 'updates the turn if it can proceed' do
      WorldTicker.any_instance.stubs(:can_process_turn? => true)
      lambda {
        put :turn, id: world.id, format: 'json'
        response.should be_success
        world.reload
      }.should change(world, :current_turn)
    end
  end

end
