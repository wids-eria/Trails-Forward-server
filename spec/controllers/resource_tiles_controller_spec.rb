require 'spec_helper'

describe ResourceTilesController do
  include Devise::TestHelpers
  render_views

  let(:player) { create :lumberjack, world: world }
  let(:user) { player.user }

  before { sign_in user }

  describe '#permitted_actions' do
    let(:world) { create :world_with_tiles }
    let(:json) { JSON.parse(response.body) }
    let(:tile_hashes) { json['resource_tiles'] }
    let(:locations) { tile_hashes.map {|tile| [tile['x'].to_i, tile['y'].to_i]} }

    context 'with signed in player' do

      context 'passed "resource_tile_ids"' do
        let(:tile_ids) { world.resource_tiles.select {|tile| tile.x % 2 == 0 && tile.y % 2 == 0}.map(&:id) }
        it 'returns a json list of the correct tiles' do
          get :permitted_actions, world_id: world.id, resource_tile_ids: tile_ids, format: 'json'
          locations.should == [[0,0], [0,2], [0,4], [2,0], [2,2], [2,4], [4,0], [4,2], [4,4]]
        end
      end

      context 'passed a world, x, y, width and height' do
        before do
          ResourceTile.any_instance.stub(can_bulldoze?: true)
          ResourceTile.any_instance.stub(can_clearcut?: false)
        end

        it 'returns JSON representing the set of resource_tiles' do
          get :permitted_actions, world_id: world.id, x: 2, y: 1, width: 2, height: 2, format: 'json'
          locations.should == [[2,1], [2,2], [3,1], [3,2]]
        end

        context 'when player does not own the tile' do
          example 'each resource_tile contains a list of permitted actions' do
            get :permitted_actions, world_id: world.id, x: 2, y: 1, width: 1, height: 1, format: 'json'
            permitted_actions = tile_hashes.map{|tile| tile['permitted_actions']}.first
            permitted_actions.should == []
          end
        end

        context 'when player owns the tile' do
          before do
            world.resource_tile_at(2, 1).megatile.update_attributes(owner: player)
          end
          example 'each resource_tile contains a list of permitted actions' do
            get :permitted_actions, world_id: world.id, x: 2, y: 1, width: 1, height: 1, format: 'json'
            permitted_actions = tile_hashes.map{|tile| tile['permitted_actions']}.first
            permitted_actions.should == ['bulldoze']
          end
        end
      end
      context 'passed top left and lower right locations' do
      end
    end
  end

  shared_examples_for 'resource tile changing action' do
    let(:world) { create :world }

    let(:megatile) { create :megatile, world: world, owner: megatile_owner }
    let!(:resource_tile) { create :resource_tile, world: world, megatile: megatile }

    context 'passed an unowned tile' do
      let(:megatile_owner) { create :player }

      it 'raises an access denied error' do
        lambda{
          post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
        }.should raise_error(CanCan::AccessDenied, 'You are not authorized to access this page.')
      end
    end

    context 'passed an owned tile' do
      let(:megatile_owner) { player }
      context "and requesting a permitted action" do
        before do
          ResourceTile.any_instance.stub("can_#{action}?".to_sym => true)
          ResourceTile.any_instance.should_receive("#{action}!".to_sym)
        end

        it "calls action on the passed in tile" do
          post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
          response.should be_success
        end
      end

      context "and requesting a non-supported action for the tile type" do
        subject { response }
        before do
          ResourceTile.any_instance.stub("can_#{action}?".to_sym => false)
          post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
        end

        it { should be_forbidden }
        its(:body) { should =~ /Action illegal for this land/ }
      end
    end

    context 'passed a list of tiles' do
      let!(:land_tile1) { create :land_tile, world: world, megatile: megatile }
      let!(:land_tile2) { create :land_tile, world: world, megatile: megatile }
      let!(:land_tiles) { [land_tile1, land_tile2] }
      let(:megatile_owner) { player }

      context 'that are all actionable' do
        it "calls action on all the passed in tiles" do
          LandTile.any_instance.should_receive("#{action}!".to_sym).any_number_of_times
          post "#{action}_list", world_id: world.id, resource_tile_ids: land_tiles.map(&:id).map(&:to_s), format: 'json'
#response.body.should == 'fubar'
        end
      end
      context 'containing 1 non-actionable tile' do
        it "effectively takes the action on none of the tiles"
      end
    end
  end

  describe '#clearcut' do
    let(:action) { :clearcut }
    it_should_behave_like "resource tile changing action"
  end

  describe '#bulldoze' do
    let(:action) { :bulldoze }
    it_should_behave_like "resource tile changing action"
  end
end
