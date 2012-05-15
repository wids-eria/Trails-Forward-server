require 'spec_helper'

describe PlayersController do
  include Devise::TestHelpers
  render_views

  describe '#index' do
    let(:user) { player.user }
    let(:player) { create :lumberjack }
    let(:other_user) { other_player.user }
    let(:other_player) { create :developer }
    let(:json) { JSON.parse(response.body) }

    before do
      sign_in user_to_sign_in
      get :index, user_id: user.id, format: 'json'
    end

    context 'logged in as another user' do
      let(:user_to_sign_in) { other_user }

      it "returns a public JSON representation of the user's players" do
        json.should == {"players" => [ {"id"=>player.id,
                                        "name"=> player.user.name,
                                        "type"=>"Lumberjack",
                                        "world_id"=>player.world.id,
                                        "world_name"=>player.world.name} ] }
      end
    end

    context 'logged in as the requested user' do
      let(:user_to_sign_in) { user }

      it "returns a private JSON representation of the user's players" do
        json.should == {"players" => [ {"id"=>player.id,
                                        "name"=> player.user.name,
                                        "type"=>"Lumberjack",
                                        "world_id"=>player.world.id,
                                        "world_name"=>player.world.name,
                                        "balance"=>player.balance} ] }
      end
    end
  end
end
