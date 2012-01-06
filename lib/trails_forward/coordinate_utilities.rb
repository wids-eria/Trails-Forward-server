module TrailsForward
  module CoordinateUtilities
    def collect_coordinates(width, height, options = {:step => 1})
      (0...width).step(options[:step]).collect do |x|
        (0...height).step(options[:step]).collect do |y|
          [x, y]
        end
      end.inject(:+)
    end

    def each_coordinate(width, height, options = {:step => 1}, &blk)
      collect_coordinates(width, height, options).each do |x, y|
        yield x, y
      end
    end
  end
end
