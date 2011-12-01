WVPairing = Struct.new :weight, :value

def random_element(weights, values)
  pairings = []
  weights.count.times do |i|
    pairings << WVPairing.new(weights[i], values[i])
  end

  pairings.sort! {|x,y| y.weight <=> x.weight}
  preceding_value = 0.0
  pairings.count.times  do |i|
    pairings[i].weight += preceding_value
    preceding_value = pairings[i].weight
  end

  our_random_number = rand
  pairings.count.times do |i|
    current_weight = pairings[i].weight
    if our_random_number < current_weight
      return pairings[i].value
    end
  end
end
