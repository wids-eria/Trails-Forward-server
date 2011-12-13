
require 'spec_helper'

describe ResourceTilesController do
  include Devise::TestHelpers
  render_views

  describe '#clearcut' do
    let(:world) { create :world }
    let(:player) { create :lumberjack, world: world }
    let(:user) { player.user }
    let(:megatile) { create :megatile, world: world, owner: megatile_owner }
    let!(:water_tile) { create :water_tile, world: world, megatile: megatile }

    before { sign_in user }

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
      let(:passed_tile) { create :land_tile, world: world, megatile: megatile, zoned_use: 'Logging' }
      let(:megatile_owner) { player }
      subject { response }
      before { post :clearcut, :world_id => world.id, :id => passed_tile.id, format: 'json' }

      it { should be_success }
    end
  end
end
