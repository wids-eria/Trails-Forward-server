
require 'spec_helper'

describe ResourceTilesController do
  include Devise::TestHelpers
  render_views

  shared_examples_for 'resource tile changing action' do

    let(:world) { create :world }
    let(:player) { create :lumberjack, world: world }
    let(:user) { player.user }
    let(:megatile) { create :megatile, world: world, owner: megatile_owner }
    let!(:resource_tile) { create :resource_tile, world: world, megatile: megatile }

    before { sign_in user }

    context 'passed an unowned tile' do
      let(:megatile_owner) { create :player }

      it 'raises an access denied error' do
        lambda{
          post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
        }.should raise_error(CanCan::AccessDenied, 'You are not authorized to access this page.')
      end
    end

    context "passed a resource tile the user can perform action on" do
      let(:megatile_owner) { player }

      it "calls action on the passed in tile" do
        ResourceTile.any_instance.should_receive("can_#{action}?".to_sym).and_return(true)
        ResourceTile.any_instance.should_receive("#{action}!".to_sym)
        post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
        response.should be_success
      end
    end

    context "passed a resource tile the user cannot perform action on" do
      let(:megatile_owner) { player }
      subject { response }
      before do
        ResourceTile.any_instance.should_receive("can_#{action}?".to_sym).and_return(false)
        post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
      end

      it { should be_forbidden }
      its(:body) { should =~ /Action illegal for this land/ }
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
