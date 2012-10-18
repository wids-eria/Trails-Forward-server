require 'spec_helper'

describe LoggingEquipment do
  let(:template) { build :logging_equipment_template }
  it 'creates equipment from a template' do
    equipment = LoggingEquipment.generate_from(template)

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
end
