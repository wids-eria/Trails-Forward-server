class Contract < ActiveRecord::Base
  belongs_to :contract_template
  belongs_to :world
  belongs_to :player
  has_and_belongs_to_many :included_megatiles, :join_table => 'contract_included_megatiles', :association_foreign_key => :megatile_id, :class_name => 'Megatile'
  has_and_belongs_to_many :attached_megatiles, :join_table => 'contract_attached_megatiles', :association_foreign_key => :megatile_id, :class_name => 'Megatile'

  validates :world, presence: true
  validates :contract_template_id, presence: true
end
