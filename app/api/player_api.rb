module PlayerApi
  extend ActiveSupport::Concern
  included do
    api_accessible :id_and_name do |template|
      template.add :id
      template.add 'user.name', :as => :name
      template.add 'user.id', :as => :user_id
      template.add :type
      template.add :world_id
      template.add 'world.name', :as => :world_name
    end

    api_accessible :player_public, :extend => :id_and_name do |template|
      # template.add :megatiles, :template => :id_and_name
    end

    api_accessible :player_private, :extend => :player_public do |template|
      template.add :balance
      template.add :pending_balance
      template.add :time_remaining_this_turn
      template.add :quest_points
      template.add :quests
    end

    api_accessible :player_private_with_megatiles, :extend => :player_private do |template|
      template.add :megatiles, :template => :id_and_name
    end

    api_accessible :player_public_with_megatiles, :extend => :player_public do |template|
      template.add :megatiles, :template => :id_and_name
    end
  end
end
