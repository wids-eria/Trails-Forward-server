class Resource < ActiveRecord::Base
  belongs_to :resource_tile
  belongs_to :world

  def self.resources_in_world world
    world.resources.where(type: self.name)
  end
end
