
require 'spec_helper'

describe ResourceTilesController do
  include Devise::TestHelpers
  render_views

  let(:world) { create :world }
  let(:player) { create :lumberjack, world: world }
  let(:user) { player.user }
  let(:megatile) { create :megatile, world: world, owner: megatile_owner }
  let!(:land_tile) { create :land_tile, world: world, megatile: megatile, zoned_use: 'Logging' }
  let!(:water_tile) { create :water_tile, world: world, megatile: megatile }

  before { sign_in user }

  describe '#clearcut' do

    context 'passed an unowned tile' do
      let(:passed_tile) { water_tile }
      let(:megatile_owner) { create :player }

      it 'raises an access denied error' do
        lambda{
          post :clearcut, :world_id => world.id, :id => passed_tile.id, format: 'json'
        }.should raise_error(CanCan::AccessDenied, 'You are not authorized to access this page.')
      end
    end

    context 'passed a resource tile that cannot be clearcut' do
      let(:passed_tile) { water_tile }
      let(:megatile_owner) { player }
      subject { response }
      before { post :clearcut, :world_id => world.id, :id => passed_tile.id, format: 'json' }

      it { should be_forbidden }
      its(:body) { should =~ /Action illegal for this land/ }
    end

    context 'passed a resource tile that can be clearcut' do
      let(:passed_tile) { land_tile }
      let(:megatile_owner) { player }
      before { post :clearcut, :world_id => world.id, :id => passed_tile.id, format: 'json' }

      it 'responds with success' do
        response.should be_success
      end
      it 'clearcuts the resource tile' do
        passed_tile.reload.tree_density.should == 0
      end
    end
  end

  describe '#bulldoze' do

    context 'passed an unowned tile' do
      let(:passed_tile) { land_tile }
      let(:megatile_owner) { create :player }

      it 'raises an access denied error' do
        lambda{
          post :bulldoze, :world_id => world.id, :id => passed_tile.id, format: 'json'
        }.should raise_error(CanCan::AccessDenied, 'You are not authorized to access this page.')
      end
    end

    context 'passed a resource tile that cannot be bulldozed' do
      let(:passed_tile) { water_tile }
      let(:megatile_owner) { player }
      subject { response }
      before { post :bulldoze, :world_id => world.id, :id => passed_tile.id, format: 'json' }

      it { should be_forbidden }
      its(:body) { should =~ /Action illegal for this land/ }
    end

    context 'passed a resource tile that can be bulldozed' do
      let(:passed_tile) { land_tile }
      let(:megatile_owner) { player }

      it 'bulldozes the passed in tile' do
        LandTile.any_instance.should_receive(:bulldoze!)
        post :bulldoze, :world_id => world.id, :id => passed_tile.id, format: 'json'
        response.should be_success
      end
    end
  end
end
