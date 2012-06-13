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

  describe '#turn_state' do
    it 'returns time in seconds' do
      WorldTurn.any_instance.stubs(:turn_duration => 30.minutes)
      get :turn_state, id: world.id, format: 'json'
      response.should be_success
      json["time_left"].should be_within(2.0).of(1499)
    end
  end
end
