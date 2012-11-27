require 'spec_helper'

describe RepoMan do
  describe '#visit' do
    let(:world) { create :world }
    let(:player) { create :lumberjack, world: world, logging_equipment: [equipment, sawyer_crew], contracts: [contract] }
    let(:equipment_template) { create :logging_equipment_template }
    let(:equipment) { LoggingEquipment.generate_from(equipment_template) }
    let(:sawyer_crew) { LoggingEquipment.generate_from(equipment_template) }
    let(:contract) { create :contract_lumberjack }

    before do
      equipment.world = world
      equipment.save!
      sawyer_crew.world = world
      sawyer_crew.name = "Sawyer Crew"
      sawyer_crew.save!
    end

    it 'takes players contracts, land, and equipment except sawyer crew if balance below 0' do
      player.balance = -100
      RepoMan.visit player
      player.save!
      player.reload
      player.balance.should == Player.default_balance
      player.logging_equipment.should == [sawyer_crew]
      equipment.reload.player.should == nil
      player.contracts.should == []
    end

    it 'leaves player alone if he has money' do
      player.balance = 100
      RepoMan.visit player
      player.save!
      player.reload
      player.balance.should == 100
      player.contracts.should == [contract]
      player.logging_equipment.should == [equipment, sawyer_crew]
    end
  end
end
