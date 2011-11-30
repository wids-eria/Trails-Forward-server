#Superclass for species specific tickers
class SpeciesTicker
  def self.tick(critter_ticker)
    raise "Not implemented"
  end

  def self.compute_habitat(matrix)
    raise "Not implemented"
  end
end

HabitatOutput = Struct.new(:count, :population, :habitat)
