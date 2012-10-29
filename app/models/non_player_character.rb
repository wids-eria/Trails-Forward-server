class NonPlayerCharacter < ActiveRecord::Base
  belongs_to :world
  validates :world_id, :type, :presence => true

  def self.attributes_protected_by_default
    ["id"]
  end
  def name_and_world
    "#{name} (World #{world_id})"
  end
end
