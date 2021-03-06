require 'spec_helper'

describe LoggingEquipment do
  let(:template) { build :logging_equipment_template }
  let(:equipment) { LoggingEquipment.generate_from(template) }

  it 'creates equipment from a template' do
    equipment.logging_equipment_template.should == template
    equipment.name.should == template.name
    equipment.equipment_type.should == template.equipment_type
    equipment.market_description.should == template.market_description

    equipment.diameter_range_min.should == template.diameter_range_min.to_f
    equipment.diameter_range_max.should == template.diameter_range_max.to_f

    equipment.initial_cost.between?(template.initial_cost_min, template.initial_cost_max).should == true
    equipment.operating_cost.between?(template.operating_cost_min, template.operating_cost_max).should == true
    equipment.maintenance_cost.between?(template.maintenance_cost_min, template.maintenance_cost_max).should == true

    equipment.harvest_volume.between?(template.harvest_volume_min, template.harvest_volume_max).should == true
    equipment.yarding_volume.between?(template.yarding_volume_min, template.yarding_volume_max).should == true
    equipment.transport_volume.between?(template.transport_volume_min, template.transport_volume_max).should == true

    equipment.condition.between?(template.condition_min, template.condition_max).should == true
    equipment.reliability.between?(template.reliability_min, template.reliability_max).should == true
    equipment.decay_rate.between?(template.decay_rate_min, template.decay_rate_max).should == true
    equipment.scrap_value.between?(template.scrap_value_min, template.scrap_value_max).should == true
  end


  context 'equipment sums' do
    let(:equipment2) { LoggingEquipment.generate_from(template) }
    let(:player) { build :player, logging_equipment: [equipment, equipment2] }

    before do
      equipment.harvest_volume = 1000
      equipment.operating_cost = 400
      equipment.diameter_range_min = 2
      equipment.diameter_range_max = 12

      equipment2.harvest_volume = 500
      equipment2.operating_cost = 250
      equipment2.diameter_range_min = 2
      equipment2.diameter_range_max = 22
    end

    describe '#harvest_volume_for' do
      it 'returns harvest volume' do
        LoggingEquipment.harvest_volume_for(diameter: 12, equipment: player.logging_equipment).should == 1500
      end

      it 'excludes equipment if it is outside diameter range' do
        LoggingEquipment.harvest_volume_for(diameter: 14, equipment: player.logging_equipment).should == 500
      end
    end

    describe '#operational_cost_for' do
      it 'returns harvest volume' do
        LoggingEquipment.operating_cost_for(diameter: 12, equipment: player.logging_equipment).should == 650
      end

      it 'excludes equipment if it is outside diameter range' do
        LoggingEquipment.operating_cost_for(diameter: 14, equipment: player.logging_equipment).should == 250
      end
    end
  end

  context 'for player' do
    describe '#logging_equipment' do
      let!(:sawyer_template) { create :logging_equipment_template, name: 'Sawyer Crew' }

      it 'is assigned a sawyer crew from template' do
        player = create(:player)
        player.reload.logging_equipment.count.should == 1
        player.reload.logging_equipment.first.name.should == "Sawyer Crew"
      end

      it 'creates crew atomically' do
        player = create(:player)
        crew = player.logging_equipment.first
        player.reload.create_default_sawyer_crew_logging_equipment
        player.reload.logging_equipment.should == [crew]
      end
    end
  end
end
