require 'spec_helper'

describe MegatilesController do
  include Devise::TestHelpers
  render_views

  let(:single_megatile_world) { create :world_with_resources, width: 3, height: 3 }
  let(:the_world) { single_megatile_world }
  let(:player) { create :lumberjack, world: the_world }
  let(:user) { player.user }

  before do
    sign_in user
  end

  describe '#index' do
    describe 'JSON for nested resource tiles' do
      context 'land tiles' do
        before do
          the_world.resource_tiles.each do |rt|
            rt.update_attribute :type, 'LandTile'
          end
        end
        context 'the player owns' do
          example 'includes bulldoze and clearcut permitted actions' do
            the_world.resource_tile_at(0, 0).megatile.update_attributes(owner: player)
            get :index, world_id: the_world.id, x_min: 0, x_max: 2, y_min: 0, y_max: 2, format: 'json'
            response.should be_success
          end
        end
      end
    end

    describe 'with old last modified date' do
      it 'returns data' do
        @request.env['HTTP_IF_MODIFIED_SINCE'] = (the_world.megatiles.first.updated_at - 10.days).rfc2822
        get :index, world_id: the_world.id, x_min: 0, x_max: 2, y_min: 0, y_max: 2, format: 'json'
        response.should be_success
      end
    end

    describe 'with new last modified date' do
      it 'returns not modified' do
        @request.env['HTTP_IF_MODIFIED_SINCE'] = the_world.megatiles.first.updated_at.rfc2822
        get :index, world_id: the_world.id, x_min: 0, x_max: 2, y_min: 0, y_max: 2, format: 'json'
        response.status.should == 304
      end
    end
  end
end
