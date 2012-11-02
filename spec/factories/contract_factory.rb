# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contract do
    contract_template { FactoryGirl.create :contract_template}
    world {FactoryGirl.create :world_with_properties_and_users }
    month_started nil
    month_ended nil
    ended false
    successful false
    on_time false
    volume_harvested_of_required_type nil
  end

  factory :contract_lumberjack, parent: :contract do
    contract_template { FactoryGirl.create :contract_template_lumberjack}
  end
end
