class Message < ActiveRecord::Base
  belongs_to :recipient, class_name: 'Player'
  belongs_to :sender,    class_name: 'Player'

  validates :subject, :body, :sender_id, :recipient_id, presence: true
  attr_accessible :subject, :body, :recipient_id
end
