class Flycatcher < Agent
  state_machine :state, :initial => :migrated do
    event :seek_nest do
      transition :migrated => :seeking_nest
    end

    event :nest do
      transition :seeking_nest => :nested
    end

    event :migrate do
      transition :all => :migrated
    end
  end

  def returned_perc
    1.0 / (1 + Math::E ** -(6 * (world.current_date.yday - 114) / 15.0))
  end

  def should_return?
    rand < return_chance
  end
end
