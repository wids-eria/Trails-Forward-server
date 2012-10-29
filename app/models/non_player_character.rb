class NonPlayerCharacter < ActiveRecord::Base
  belongs_to :world
  validates :world_id, :type, :presence => true

  def name_and_world
    "#{name} (World #{world_id})"
  end
end
