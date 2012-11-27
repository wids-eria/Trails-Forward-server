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
  end

  let(:shared_params) { {world_id: the_world.to_param, format: 'json'} }
  let(:json) { JSON.parse(response.body) }

  describe '#index' do
    describe 'JSON for nested resource tiles' do
      it 'returns only id coordinates and timestamp' do
        the_world.resource_tile_at(0, 0).megatile.update_attributes(owner: player)
        get :index, world_id: the_world.id, x_min: 0, x_max: 2, y_min: 0, y_max: 2, format: 'json'
        response.should be_success
        json['megatiles'].first.keys.should == ['id', 'x', 'y', 'updated_at']
      end
    end
  end

  describe '#owned' do
    let(:megatile) { the_world.megatiles.first }

    it 'returns your players owned tiles for world' do
      megatile.update_attributes owner: player

      get :owned, shared_params

      response.should be_success
      json['megatiles'].count.should == 1
      json['megatiles'].first['id'].should == megatile.id
    end

    it 'doesnt return unowned tiles for world' do
      megatile.update_attributes owner: player2

      get :owned, shared_params

      response.should be_success
      json['megatiles'].count.should == 0
    end
  end

  describe '#show' do
    let(:megatile) { the_world.megatiles.first }

    before do
      the_world.resource_tiles.each do |rt|
        rt.update_attribute :type, 'LandTile'
      end

      the_world.resource_tiles.first.update_attribute :type, 'LandTile'
      the_world.resource_tiles.last.update_attribute  :type, 'WaterTile'
    end

    describe 'with old last modified date' do
      # NOTE make sure water tiles return tree info so client doesnt barf.
      # FIXME for eventual removal.
      it 'returns trees on water tiles and land tiles' do
        @request.env['HTTP_IF_MODIFIED_SINCE'] = (megatile.updated_at - 10.days).rfc2822
        get :show, world_id: the_world.id,  id: megatile.id, format: 'json'
        response.should be_success

         land_tile = json['megatile']['resource_tiles'].first
        water_tile = json['megatile']['resource_tiles'].last

         land_tile.keys.include?('num_2_inch_diameter_trees').should be_true
        water_tile.keys.include?('num_2_inch_diameter_trees').should be_true
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

    it 'can be bought and you go into debt if you dont have enough' do
      player.balance = 10
      player.save!

      put :buy, world_id: the_world.to_param, id: megatile.to_param, format: :json
      response.status.should == 200

      megatile.reload
      megatile.owner.should == player

      player.reload
      player.balance.should < 0

    end
  end

end
