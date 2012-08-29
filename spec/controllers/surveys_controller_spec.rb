require 'spec_helper'

describe SurveysController do
  include Devise::TestHelpers
  render_views

  let(:single_megatile_world) { create :world_with_resources, width: 3, height: 3 }
  let(:the_world) { single_megatile_world }
  let(:megatile ) { the_world.megatiles.first }
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

      response.should be_success
      survey = assigns(:survey)
      survey.num_2in_trees.should == megatile.resource_tiles.collect{|rt| rt.num_2_inch_diameter_trees}.sum

      survey.player.should == player

      player.reload
      player.balance.should == 975
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

  describe 'listing Surveys' do
    let!(:my_survey1) { create :survey, megatile: megatile, player: player}
    let!(:my_survey2) { create :survey, megatile: megatile, player: player}
    let!(:other_survey) { create :survey, megatile: megatile, player: player2}

    it 'returns my surveys for that megatile' do
      get :index, world_id: the_world.to_param, megatile_id: megatile.to_param, format: :json
      response.should be_success
      assigns(:surveys).should == [my_survey1 , my_survey2]
    end
  end
end
