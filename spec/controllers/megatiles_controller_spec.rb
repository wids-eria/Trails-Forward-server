require 'spec_helper'

describe MegatilesController do
  include Devise::TestHelpers
  render_views

  let(:single_megatile_world) { create :world_with_resources, width: 3, height: 3 }
  let(:the_world) { single_megatile_world }
  let(:player)  { create :lumberjack, world: the_world }
  let(:player2) { create :lumberjack, world: the_world }
  let(:user) { player.user }

  before do
    sign_in user

    create :megatile_region_cache, world: the_world, megatiles: the_world.megatiles
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
  end
  
  describe '#show' do 
    let(:megatile) { the_world.megatiles.first }
    describe 'with old last modified date' do
      it 'returns data' do
        @request.env['HTTP_IF_MODIFIED_SINCE'] = (megatile.updated_at - 10.days).rfc2822
        get :show, world_id: the_world.id,  id: megatile.id, format: 'json'
        response.should be_success
      end
    end
    
    describe 'with new last modified date' do
      it 'returns not modified' do
        @request.env['HTTP_IF_MODIFIED_SINCE'] = megatile.updated_at.rfc2822
        get :show, world_id: the_world.id, id: megatile.id,  format: 'json'
        response.status.should == 304
      end
    end    
  end

  describe '#buy' do
    let(:megatile) { the_world.megatiles.first }

    it 'becomes yours and funds are removed' do
      player.balance = 1000
      player.save!
      put :buy, world_id: the_world.to_param, id: megatile.to_param, format: :json
      response.status.should == 200

      megatile.reload
      megatile.owner.should == player

      player.reload
      player.balance.should == 900
    end

    it 'doesnt become yours if owned' do
      player.balance = 1000
      player.save!
      megatile.owner = player2
      megatile.save!

      put :buy, world_id: the_world.to_param, id: megatile.to_param, format: :json
      response.status.should == 422

      megatile.reload
      megatile.owner.should == player2

      player.reload
      player.balance.should == 1000
    end

    it 'doesnt become yours if you dont have enough' do
      player.balance = 10
      player.save!

      put :buy, world_id: the_world.to_param, id: megatile.to_param, format: :json
      response.status.should == 422

      megatile.reload
      megatile.owner.should be_nil

      player.reload
      player.balance.should == 10

    end
  end

end
