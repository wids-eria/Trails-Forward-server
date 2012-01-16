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
    world.resource_tiles.each do |rt|
      rt.update_attribute :type, 'LandTile'
    end
  end

  describe '#index' do
    describe 'JSON for nested resource tiles' do
      context 'player owns the land tile' do
        example 'includes bulldoze and clearcut permitted actions' do
          world.resource_tile_at(0, 0).megatile.update_attributes(owner: player)
          get :index, world_id: world.id, x_min: 0, x_max: 2, y_min: 0, y_max: 2, format: 'json'
          json = JSON.parse(response.body)
          megatile_hashes = json['megatiles']
          tile_hashes = megatile_hashes.map{|megatile| megatile['resource_tiles']}.first
          permitted_actions = tile_hashes.map{|tile| tile['permitted_actions']}
          permitted_actions.should == Array.new(9) { ['bulldoze', 'clearcut'] }
        end
      end

      context 'player does not own the land tile' do
        example 'includes no permitted actions' do
          get :index, world_id: world.id, x_min: 0, x_max: 2, y_min: 0, y_max: 2, format: 'json'
          json = JSON.parse(response.body)
          megatile_hashes = json['megatiles']
          tile_hashes = megatile_hashes.map{|megatile| megatile['resource_tiles']}.first
          permitted_actions = tile_hashes.map{|tile| tile['permitted_actions']}
          permitted_actions.should == Array.new(9) { [] }
        end
      end
    end
  end

  # describe '#permitted_actions' do
  #   let(:world) { create :world_with_tiles }
  #   let(:json) { JSON.parse(response.body) }
  #   let(:tile_hashes) { json['resource_tiles'] }
  #   let(:locations) { tile_hashes.map {|tile| [tile['x'].to_i, tile['y'].to_i]} }

  #   context 'with signed in player' do

  #     context 'passed "microtiles"' do
  #       let(:tile_ids) { world.resource_tiles.select {|tile| tile.x % 2 == 0 && tile.y % 2 == 0}.map(&:id) }
  #       it 'returns a json list of the correct tiles' do
  #         get :permitted_actions, world_id: world.id, microtiles: tile_ids, format: 'json'
  #         locations.should == [[0,0], [0,2], [0,4], [2,0], [2,2], [2,4], [4,0], [4,2], [4,4]]
  #       end
  #     end

  #     context 'passed a world, x, y, width and height' do
  #       before do
  #         ResourceTile.any_instance.stub(can_bulldoze?: true)
  #         ResourceTile.any_instance.stub(can_clearcut?: false)
  #       end

  #       it 'returns JSON representing the set of resource_tiles' do
  #         get :permitted_actions, world_id: world.id, x: 2, y: 1, width: 2, height: 2, format: 'json'
  #         locations.should == [[2,1], [2,2], [3,1], [3,2]]
  #       end

  #       context 'when player does not own the tile' do
  #         example 'each resource_tile contains a list of permitted actions' do
  #           get :permitted_actions, world_id: world.id, x: 2, y: 1, width: 1, height: 1, format: 'json'
  #           permitted_actions = tile_hashes.map{|tile| tile['permitted_actions']}.first
  #           permitted_actions.should == []
  #         end
  #       end

  #       context 'when player owns the tile' do
  #         before do
  #           world.resource_tile_at(2, 1).megatile.update_attributes(owner: player)
  #         end
  #         example 'each resource_tile contains a list of permitted actions' do
  #           get :permitted_actions, world_id: world.id, x: 2, y: 1, width: 1, height: 1, format: 'json'
  #           permitted_actions = tile_hashes.map{|tile| tile['permitted_actions']}.first
  #           permitted_actions.should == ['bulldoze']
  #         end
  #       end
  #     end
  #     context 'passed top left and lower right locations' do
  #     end
  #   end
  # end
end
