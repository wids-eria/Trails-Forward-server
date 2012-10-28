
FactoryGirl.define do
  factory :contract_template do
    world { FactoryGirl.create :world_with_properties_and_users }
    difficulty "easy"
    acres_added_required 0
    acres_developed_required nil
    home_type nil
    description "MyText"
    acceptance_message "MyText"
    complete_message "MyText"
    late_message "MyText"
    points_required_to_unlock 0
    points 10
    dollars 100
    deadline 12
    includes_land false
  end

  factory :contract_template_lumberjack, parent: :contract_template do
    codename "FACTORY_LUMBERJACK_DEFAULT"
    role "Lumberjack"
    volume_required 10
    wood_type "saw_timber"
  end

  factory :contract_template_developer, parent: :contract_template do
    codename "FACTORY_DEVELOPER_DEFAULT"
    role "Developer"
    home_type LandTile::Vacation
    acres_developed_required  6
  end

end
