class Patch
  include Mongoid::Document
  include Mongoid::Spacial::Document
  include LocativeDocumentInWorld
  
  #validates_uniqueness_of :_x, :scope => [:_y, :mundo_id]
  #validates_uniqueness_of :_y, :scope => [:_x, :mundo_id]
  
  def self.new_in_mundo_at_x_y(mundo, x, y)
    p = Patch.new
    p.mundo = mundo
    p.x = x
    p.y = y
    
    p
  end
  
end
