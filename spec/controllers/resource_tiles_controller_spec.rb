require 'spec_helper'

describe ResourceTilesController do
  include Devise::TestHelpers
  render_views

  let(:world) { create :world_with_tiles }
  let(:player) { create :lumberjack, world: world, balance: 1000 }
  let(:player2) { create :lumberjack, world: world }
  let(:user) { player.user }
  let(:json) { JSON.parse(response.body) }

  before { sign_in user }

  describe '#permitted_actions' do
    let(:tile_hashes) { json['resource_tiles'] }
    let(:locations) { tile_hashes.map {|tile| [tile['x'].to_i, tile['y'].to_i]} }
    let(:ids) { tile_hashes.map{|tile| tile['id'] } }

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
          ResourceTile.any_instance.stubs(can_bulldoze?: true)
          ResourceTile.any_instance.stubs(can_clearcut?: false)
        end

        it 'returns JSON representing the set of resource_tiles' do
          get :permitted_actions, world_id: world.id, x_min: 2, y_min: 1, x_max: 3, y_max: 2, format: 'json'
          locations.should == [[2,1], [2,2], [3,1], [3,2]]
        end

        context 'when other worlds present' do
          let!(:other_tile) { create :resource_tile, x: 2, y: 2 }
          it 'doesnt return tiles from them' do
            get :permitted_actions, world_id: world.id, x_min: 1, y_min: 1, x_max: 3, y_max: 3, format: 'json'
            ids.should_not include(other_tile.id)
          end
        end

        context 'when player does not own the tile' do
          example 'each resource_tile contains a list of permitted actions' do
            get :permitted_actions, world_id: world.id, x_min: 2, y_min: 1, x_max: 2, y_max: 1, format: 'json'
            permitted_actions = tile_hashes.map{|tile| tile['permitted_actions']}.first
            permitted_actions.should == []
          end
        end

        context 'when player owns the tile' do
          before do
            world.resource_tile_at(2, 1).megatile.update_attributes(owner: player)
          end
          example 'each resource_tile contains a list of permitted actions' do
            get :permitted_actions, world_id: world.id, x_min: 2, y_min: 1, x_max: 2, y_max: 1, format: 'json'
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
          ResourceTile.any_instance.stubs("can_#{action}?".to_sym => true)
          ResourceTile.any_instance.expects("#{action}!".to_sym)
        end

        it "calls action on the passed in tile" do
          post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
          response.should be_success
        end
      end

      context "and requesting a non-supported action for the tile type" do
        subject { response }
        before do
          ResourceTile.any_instance.stubs("can_#{action}?".to_sym => false)
          post action, :world_id => world.id, :id => resource_tile.id, format: 'json'
        end

        it { should be_forbidden }
        its(:body) { should =~ /Action illegal for this land/ }
      end
    end

    context 'passed a list of tiles' do
      let(:land_tile1) { create :forest_tile, world: world, megatile: megatile }
      let(:land_tile2) { create :forest_tile, world: world, megatile: megatile }
      let(:land_tiles) { [land_tile1, land_tile2] }
      let(:megatile_owner) { player }

      context 'that are all actionable' do
        it "calls action on all the passed in tiles" do
          megatile.update_attributes(owner: player)
          post "#{action}_list", world_id: world.id, resource_tile_ids: land_tiles.map(&:id).map(&:to_s), format: 'json'
          response.should be_success
        end
      end
      context 'containing 1 non-actionable tile' do
        let(:water_tile) { create :water_tile, world: world, megatile: megatile }
        let(:tiles) { [land_tile1, water_tile] }

        it "effectively takes the action on none of the tiles" do
          megatile.update_attributes(owner: player)
          post "#{action}_list", world_id: world.id, resource_tile_ids: tiles.map(&:id).map(&:to_s), format: 'json'
          response.should_not be_success
        end
      end
    end
  end


  describe '#build_outpost' do
    let(:world) { create :world_with_tiles }
    let(:player) { create :developer, world: world }
    let(:user) { player.user }
    
    it 'makes the tiles around it surveyable' do
      rt = world.resource_tile_at 1,1
      rt.landcover_class_code = 21
      rt.zoning_code = 4
      rt.save!
      megatile = rt.megatile
      megatile.owner = player
      megatile.save!
      
      post 'build_outpost', world_id: world.to_param, id: rt.id, format: 'json', god_mode: 'iddqd'

      response.body.should have_content('resource_tiles')
    end
  end
  
  describe '#build' do
    let(:world) { create :world_with_resources }
    let(:player) { create :developer, world: world }
    let(:user) { player.user }
    
    it 'builds a vacation home' do
      pine_sawtimber_used_before = world.pine_sawtimber_used_this_turn    
      player_balance_before = player.balance  
      rt = world.resource_tile_at 1,1
      rt.type = 'LandTile'
      rt.save!
      rt.reload
      
      mt = rt.megatile
      rt.can_build?().should == true
      
      mt.owner = player
      mt.save!
      
      post 'build', world_id: world.to_param, id: rt.id, format: 'json', type: "vacation"
      response.body.should have_content('resource_tile')
      world.reload
      player.reload
      world.pine_sawtimber_used_this_turn.should > pine_sawtimber_used_before
      player_balance_before.should > player.balance
    end
  end
  

  context 'harvesting' do
    let(:world) { create :world }
    let(:megatile) { create :megatile, owner: player, world: world }
    let!(:land_tile1) { create :coniferous_land_tile, world: world, megatile: megatile }
    let!(:land_tile2) { create :coniferous_land_tile, world: world, megatile: megatile }
    let!(:unharvestable_tile) { create :residential_land_tile, world: world, megatile: megatile }
    let!(:bad_land_tile) { create :coniferous_land_tile, world: world, megatile: megatile }

    let(:other_megatile) { create :megatile, owner: player2, world: world }
    let!(:other_tile) { create :deciduous_land_tile, world: world, megatile: other_megatile }

    let!(:tiles) { [land_tile1, land_tile2] }

    before do
      land_tile1.species_group.should == :shade_intolerant
      land_tile2.species_group.should == :shade_intolerant
    end

    describe '#diameter_limit_cut' do
      it 'returns values and volumes of all the tiles cut' do
        old_timber_count = world.pine_sawtimber_cut_this_turn

        sawyer_results1 = land_tile1.diameter_limit_cut above: 12
        sawyer_results2 = land_tile2.diameter_limit_cut above: 12

        post 'diameter_limit_cut_list', world_id: world.to_param, resource_tile_ids: tiles.map(&:to_param), above: 12.to_s, format: 'json'

        world.reload
        world.pine_sawtimber_cut_this_turn.should > old_timber_count

        response.body.should have_content('poletimber_value')
        response.body.should have_content(sawyer_results1[:poletimber_value] + sawyer_results2[:poletimber_value])

        response.body.should have_content('poletimber_volume')
        response.body.should have_content(sawyer_results1[:poletimber_volume] + sawyer_results2[:poletimber_volume])

        response.body.should have_content('sawtimber_value')
        response.body.should have_content(sawyer_results1[:sawtimber_value] + sawyer_results2[:sawtimber_value])

        response.body.should have_content('sawtimber_volume')
        response.body.should have_content(sawyer_results1[:sawtimber_volume] + sawyer_results2[:sawtimber_volume])
      end
    end



    describe '#clearcut' do
      it 'transacts market, player, and tile if things go wrong'


      it 'returns values and volumes of all the tiles cut' do
        old_timber_count = world.pine_sawtimber_cut_this_turn
        old_balance = player.balance

        sawyer_results1 = land_tile1.clearcut
        sawyer_results2 = land_tile2.clearcut

        post 'clearcut_list', world_id: world.to_param, resource_tile_ids: tiles.map(&:to_param), format: 'json'
        response.status.should == 200

        json['resource_tiles'].collect{|rt| rt['id']}.should == [land_tile1.id, land_tile2.id]

        json['poletimber_value' ].should == sawyer_results1[:poletimber_value ] + sawyer_results2[:poletimber_value ]
        json['poletimber_volume'].should == sawyer_results1[:poletimber_volume] + sawyer_results2[:poletimber_volume]

        json['sawtimber_value' ].should == sawyer_results1[:sawtimber_value  ] + sawyer_results2[:sawtimber_value ]
        json['sawtimber_volume'].should == sawyer_results1[:sawtimber_volume ] + sawyer_results2[:sawtimber_volume]

        world.reload.pine_sawtimber_cut_this_turn.should be_within(0.1).of(old_timber_count + sawyer_results1[:sawtimber_volume]   + sawyer_results2[:sawtimber_volume])
        player.reload.balance.should < old_balance
      end


      it 'doesnt clearcut if not owned by you' do
        old_timber_count = world.pine_sawtimber_cut_this_turn

        assert_raises CanCan::AccessDenied do
          post 'clearcut_list', world_id: world.to_param, resource_tile_ids: [other_tile].map(&:to_param), format: 'json'
        end

        world.reload.pine_sawtimber_cut_this_turn.should be_within(0.1).of(old_timber_count)
        player.reload.balance.should == 1000
      end


      it 'can clearcut if not enough money' do
        old_timber_count = world.pine_sawtimber_cut_this_turn

        player.update_attributes! balance: 2

        post 'clearcut_list', world_id: world.to_param, resource_tile_ids: tiles.map(&:to_param), format: 'json'
        response.status.should == 200

        world.reload.pine_sawtimber_cut_this_turn.should > old_timber_count
        player.reload.balance.should < 0
      end


      it 'strips out non clearcutable land' do
        bad_land_tile.update_attributes landcover_class_code: 11
        assert_nothing_raised do
          post 'clearcut_list', world_id: world.to_param, resource_tile_ids: [land_tile1, unharvestable_tile, bad_land_tile].map(&:to_param), format: 'json'
        end
        response.should be_successful
      end


      it 'updates market price from volumes harvested on applicable tiles'
    end



    describe '#partial_selection_cut' do
      it 'returns values and volumes of all the tiles cut' do
        old_timber_count = world.pine_sawtimber_cut_this_turn
        
        sawyer_results1 = land_tile1.partial_selection_cut target_basal_area: 100, qratio: 1.5
        sawyer_results2 = land_tile2.partial_selection_cut target_basal_area: 100, qratio: 1.5

        post 'partial_selection_cut_list', world_id: world.to_param, resource_tile_ids: tiles.map(&:to_param), target_basal_area: 100, qratio: 1.5, format: 'json'

        response.body.should have_content('poletimber_value')
        response.body.should have_content(sawyer_results1[:poletimber_value] + sawyer_results2[:poletimber_value])

        response.body.should have_content('poletimber_volume')
        response.body.should have_content(sawyer_results1[:poletimber_volume] + sawyer_results2[:poletimber_volume])

        response.body.should have_content('sawtimber_value')
        response.body.should have_content(sawyer_results1[:sawtimber_value] + sawyer_results2[:sawtimber_value])

        response.body.should have_content('sawtimber_volume')
        response.body.should have_content(sawyer_results1[:sawtimber_volume] + sawyer_results2[:sawtimber_volume])
        
        world.reload
        world.reload.pine_sawtimber_cut_this_turn.should == (old_timber_count + sawyer_results1[:sawtimber_volume] + sawyer_results2[:sawtimber_volume]).round
      end
    end
  end
end
