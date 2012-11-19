require 'spec_helper'

describe WorldPlayerAvailableContractsController do
  include Devise::TestHelpers

  describe 'working with available contracts' do
    let(:lumberjack_contract) { build :contract_lumberjack }
    let(:player) { create :lumberjack, :world_id => lumberjack_contract.world.id }
    let(:user) { player.user }
    let(:json) { JSON.parse(response.body) }

    before do
      lumberjack_contract.save!
      sign_in user
    end

    it '#index' do
      get :index,  world_id: player.world.to_param, player_id: player.to_param, format: :json
      response.should be_success
      found_it = false

      json["lumberjack_contracts"].each do  |contract|
        if contract["id"] == lumberjack_contract.id
          found_it = true
        end
      end
      found_it.should == true
    end

    it '#accept' do
      world = lumberjack_contract.world
      megatile = world.megatile_at 2,2
      megatile.owner = nil
      megatile.save!
      lumberjack_contract.included_megatiles << megatile
      post :accept, world_id: player.world.to_param, player_id: player.to_param, available_contract_id: lumberjack_contract.to_param, format: :json
      response.should be_success
      lumberjack_contract.reload
      player.contracts.include?(lumberjack_contract).should be_true
      megatile.reload
      megatile.owner.should == player
    end
  end #describe index
end


