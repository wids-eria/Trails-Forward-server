class Flycatcher < Agent

  property_set :settings, Agent do
    property :migrate_in_date
    property :migrate_out_date
  end

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

  def set_migrate_in_date
    migrate_day = migrate_in_yday.floor
    migrate_date = Date.strptime("#{self.world.current_date.year}-#{migrate_day}", "%Y-%j")
    self.settings.migrate_in_date = migrate_date.to_s
  end

  def migrate_in_yday
    range = 45.0
    std = range / 6.0
    mean = 114.0
    Agent.dist.gaussian(std) + mean
  end
end
