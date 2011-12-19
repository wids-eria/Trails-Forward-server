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
end
