require 'spec_helper'

describe WorldPlayerContractsController do
  include Devise::TestHelpers

  describe 'working with available contracts' do
    let(:lumberjack_contract) { build :contract_lumberjack }
    let(:player) { create :lumberjack, :world_id => lumberjack_contract.world.id }
    let(:user) { player.user }
    let(:world) { player.world }
    let(:json) { JSON.parse(response.body) }

    before do
      lumberjack_contract.player = player
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

    it '#attach_megatiles' do
      megatile = world.megatile_at 2,2
      megatile.owner = player
      megatile.save!
      lumberjack_contract.player.should == player

      post :attach_megatiles, world_id: player.world.to_param, player_id: player.to_param, contract_id: lumberjack_contract.to_param, megatile_ids: [megatile.id], format: :json
      response.should be_success
      lumberjack_contract.reload
      lumberjack_contract.attached_megatiles.include?(megatile).should be_true
    end
  end #describe index
end


