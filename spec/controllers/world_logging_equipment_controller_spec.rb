require 'spec_helper'

describe WorldLoggingEquipmentController do
  include Devise::TestHelpers
  render_views

  let(:other_world) { create :world }
  let(:world) { create :world }

  let!(:logged_in_player) { create :player, world: world, balance: 1000000 }
  let!(:other_player)     { create :player, world: world }

  let(:template) { build :logging_equipment_template }
  let(:other_world_equipment) { LoggingEquipment.generate_from(template) }
  let(:unowned_equipment)     { LoggingEquipment.generate_from(template) }
  let(:my_owned_equipment)    { LoggingEquipment.generate_from(template) }
  let(:other_owned_equipment) { LoggingEquipment.generate_from(template) }

  let(:shared_params) { {world_id: world.to_param, format: 'json'} }
  let(:json) { JSON.parse(response.body).with_indifferent_access }

  before do
    sign_in logged_in_player.user

    other_world_equipment.world = other_world
    other_world_equipment.save!

    unowned_equipment.world = world
    unowned_equipment.save!

    my_owned_equipment.world  = world
    my_owned_equipment.player = logged_in_player
    my_owned_equipment.save!

    other_owned_equipment.world  = world
    other_owned_equipment.player = other_player
    other_owned_equipment.save!
  end

  describe "GET #index" do
    it 'returns only unowned equipment for world' do
      get :index, shared_params
      response.should be_successful

      json[:logging_equipment_list].count.should == 1
      json[:logging_equipment_list].first[:id].should == unowned_equipment.id
    end
  end

  describe 'PUT #purchase' do
    it 'buys equipment from this world' do
      put :buy, shared_params.merge(id: unowned_equipment.to_param)
      response.should be_successful

      unowned_equipment.reload.player.should == logged_in_player
    end


    it 'can go into debt purchasing' do
      logged_in_player.update_attributes balance: 0

      put :buy, shared_params.merge(id: unowned_equipment.to_param)
      response.should be_successful

      unowned_equipment.reload.player.should == logged_in_player
      logged_in_player.reload.balance.should == -unowned_equipment.initial_cost.to_i
    end


    it 'cant buy equipment from other worlds' do
      starting_balance = logged_in_player.balance

      lambda do
        put :buy, shared_params.merge(id: other_world_equipment.to_param)
      end.should raise_error(ActiveRecord::RecordNotFound)

      logged_in_player.reload.balance.should == starting_balance
      other_owned_equipment.reload.player.should_not == logged_in_player
    end


    it 'cant buy owned equipment' do
      starting_balance = logged_in_player.balance

      put :buy, shared_params.merge(id: other_owned_equipment.to_param)
      response.status.should == 422

      logged_in_player.reload.balance.should == starting_balance
      other_owned_equipment.reload.player.should_not == logged_in_player
    end

    it 'transcts player and equipment saving'
  end
end
