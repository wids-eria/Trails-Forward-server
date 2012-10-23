require 'spec_helper'

describe SurveysController do
  include Devise::TestHelpers
  render_views

  let(:single_megatile_world) { create :world_with_resources, width: 3, height: 3 }
  let(:the_world) { single_megatile_world }
  let!(:megatile ) { create :megatile, world: the_world } #, resource_tiles: [land_tile, water_tile] }
  let!(:land_tile) { create :deciduous_land_tile, world: the_world, megatile: megatile }
  let!(:water_tile) { create :water_tile, world: the_world, megatile: megatile }
  let(:player   ) { create :lumberjack, world: the_world }
  let(:player2  ) { create :lumberjack, world: the_world }
  let(:user     ) { player.user }

  before do
    sign_in user
  end

  describe 'buying a survey' do
    it 'returns a survey of the land and removes funds' do
      player.balance = 1000
      player.save!

      post :create, world_id: the_world.to_param, megatile_id: megatile.to_param, format: :json

      # FIXME later. test setup data sucks. survey got stupid, or was never passing properly?
      response.should be_success
      survey = assigns(:survey)
      survey.num_2in_trees.should == megatile.resource_tiles.collect{|rt| rt.num_2_inch_diameter_trees}.sum
      survey.num_2in_trees.should > 0 

      survey.vol_6in_trees.should ==  land_tile.estimated_tree_volume_for_size(6, land_tile.num_6_inch_diameter_trees)
      survey.vol_6in_trees.should > 0 

      survey.player.should == player

      player.reload
      player.balance.should == 975
    end

    # found a bug with land with water class code..
    it 'handles land that has no trees' do
      # a data type that causes species_group to fail
      land_tile.update_attributes landcover_class_code: 11
      player.balance = 1000
      player.save!

      post :create, world_id: the_world.to_param, megatile_id: megatile.to_param, format: :json

      # FIXME later. test setup data sucks. survey got stupid, or was never passing properly?
      response.should be_success
    end

    it 'returns error if not enough funds' do
      player.balance = 10
      player.save!

      post :create, world_id: the_world.to_param, megatile_id: megatile.to_param, format: :json

      response.status.should == 422

      survey = assigns(:survey)
      survey.new_record?.should be_true

      player.reload
      player.balance.should == 10

    end
  end

  describe '#index' do
    context 'when surveys exist' do
      let!(:my_survey1) { create :survey, megatile: megatile, player: player}
      let!(:my_survey2) { create :survey, megatile: megatile, player: player}
      let!(:other_survey) { create :survey, megatile: megatile, player: player2}

      it 'returns my surveys for that megatile' do
        get :index, world_id: the_world.to_param, megatile_id: megatile.to_param, format: :json
        response.should be_success
        assigns(:surveys).should == [my_survey1 , my_survey2]
      end
    end

    context 'when no surveys exist' do
      let(:default_counts) { [272.437067809463, 99.994884114938, 45.5289670412543, 22.2937863557362, 11.0390612960499, 5.4378119957329, 2.75016842307342, 1.55739847629946, 1.07079856778977, 0.862134192795702, 0.722516967545298] }
      it 'returns a default survey' do
        get :index, world_id: the_world.to_param, megatile_id: megatile.to_param, format: :json
        response.should be_success
        harvestable_count = megatile.resource_tiles.select{|x| x.can_clearcut?}.count
        harvestable_count.should > 0
        assigns(:surveys).count.should == 1
        assigns(:surveys).first.num_2in_trees.should == default_counts[0] * harvestable_count
      end
    end
  end

  describe 'returning enough info'
end
