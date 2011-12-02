class Agent < ActiveRecord::Base
  belongs_to :resource_tile
  belongs_to :world
end
