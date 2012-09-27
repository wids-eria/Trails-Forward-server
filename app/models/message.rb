class Message < ActiveRecord::Base
  belongs_to :recipient, class_name: 'Player'
  belongs_to :sender,    class_name: 'Player'

  validates :subject, :body, :sender_id, :recipient_id, presence: true
  attr_accessible :subject, :body, :recipient_id

  def read?
    self.read_at.present?
  end

  def read
    self.read_at = DateTime.now
  end


  def archived?
    self.archived_at.present? # && self.archived_at > DateTime.now # time zone safe? write test
  end

  def archive
    self.archived_at = DateTime.now
  end
end
