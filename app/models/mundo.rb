class Mundo
  include Mongoid::Document

  field :width, type: Integer
  field :height, type: Integer
  field :name, type: String
  
  has_many :patches
  has_many :tortugas
  
  def initialize_patches
    if not (width and height)
      raise "Cannot initialize without a width and a height!"
    else
      width.times do |x|
        height.times do |y|
          p = Patch.new_in_mundo_at_x_y(self, x, y)
          p.save!
        end
      end
    end
  end
  
  def unsaved_patches
    ps = Array.new(width*height)
    i = 0
    width.times do |x|
      height.times do |y|
        ps[i] = Patch.new_in_mundo_at_x_y(self, x, y).as_document
        i+=1
      end
    end
    ps
  end

  def coords
    (0...width).collect do |x|
      (0...height).collect do |y|
        [x,y]
      end
    end.inject(:+)
  end

  def each_coord &blk
    coords.collect do |x, y|
      yield x, y
    end
  end

end
