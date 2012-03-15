require 'spec_helper'

describe MegatilesController do
  include Devise::TestHelpers
  render_views

  let(:single_megatile_world) { create :world_with_resources, width: 3, height: 3 }
  let(:world) { single_megatile_world }
  let(:player) { create :lumberjack, world: world }
  let(:user) { player.user }

  before do
    sign_in user
  end

  describe '#index' do
    describe 'JSON for nested resource tiles' do
      context 'land tiles' do
        before do
          world.resource_tiles.each do |rt|
            rt.update_attribute :type, 'LandTile'
          end
        end
        context 'the player owns' do
          example 'includes bulldoze and clearcut permitted actions' do
            world.resource_tile_at(0, 0).megatile.update_attributes(owner: player)
            get :index, world_id: world.id, x_min: 0, x_max: 2, y_min: 0, y_max: 2, format: 'json'
            response.should be_success
          end
        end
      end
    end
  end
end
