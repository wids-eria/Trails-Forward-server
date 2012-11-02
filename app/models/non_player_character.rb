class NonPlayerCharacter < ActiveRecord::Base
  validates :codename, :uniqueness => true, :presence => true

  def self.attributes_protected_by_default
    ["id"]
  end
end

