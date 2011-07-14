class ChangeRequest < ActiveRecord::Base

  belongs_to :target, :polymorphic => true
  belongs_to :world

  validates_presence_of :target
  validates_presence_of :world_id
  validates_numericality_of :world_id

  scope :pending, where(:complete => false)

  belongs_to :world

end
