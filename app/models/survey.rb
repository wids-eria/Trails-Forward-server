class Survey < ActiveRecord::Base
  has_many :survey_data
  has_many :tile_surveys, through: :survey_data

  validates :capture_date, :presence => true
end
