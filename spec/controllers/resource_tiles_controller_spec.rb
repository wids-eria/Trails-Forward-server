require 'spec_helper'

describe ResourceTilesController do
  include Devise::TestHelpers
  render_views

  let(:player) { create :lumberjack, world: world }
  let(:user) { player.user }

  before { sign_in user }

  describe '#permitted_actions' do
    let(:world) { create :world_with_resources }
    let(:json) { JSON.parse(response.body) }

    context 'with signed in player' do
      context 'passed "microtiles"' do

      end

      context 'passed x, y, width and height' do
        it 'returns JSON representing set of resource_tiles' do
          # get :permitted_actions, world_id: world.id, x: 0, y: 1, width: 2, height: 1, format: 'json'
          get :permitted_actions, world_id: world.id, x: 2, y: 1, width: 2, height: 2, format: 'json'

          json['resource_tiles'].size.should == 4

          json['resource_tiles'].first['x'].should == 2
          json['resource_tiles'].first['y'].should == 1

          json['resource_tiles'].last['x'].should == 3
          json['resource_tiles'].last['y'].should == 2

          # json['resource_tiles'].should == [ {"id" => 1,
                                              # "x" => 0,
                                              # "y" => 0,
                                              # "type" => "LandTile",
                                              # "primary_use" => "Residential",
                                              # "zoned_use" => "Development",
                                              # "people_density" => 0.849164505154221,
                                              # "housing_density" => 0.849164505154221,
                                              # "tree_density" => 0.0373858952433272,
                                              # "tree_species" => nil,
                                              # "tree_size" => nil,
                                              # "development_intensity" => 0.849164505154221,
                                              # "imperviousness" => nil}]
        end

        # example 'each resource_tile contains a list of permitted actions'
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

    context "passed a resource tile the user can perform the action on" do
      let(:megatile_owner) { player }

      it "calls action on the passed in tile" do
        ResourceTile.any_instance.should_receive("can_#{action}?".to_sym).and_return(true)
        ResourceTile.any_instance.should_receive("#{action}!".to_sym)
        post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
        response.should be_success
      end
    end

    context "passed a resource tile the user cannot perform the action on" do
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
