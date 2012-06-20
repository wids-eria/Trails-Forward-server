module TurnScheduler
  SLOG = Logger.new(File.join("log", "scheduler"), 'daily')
  def self.mark_for_processing
    SLOG.info "marking for processing"
    World.in_play.each do |world|
      manager = WorldTurn.new world: world
      if manager.can_process_turn?
        manager.mark_for_processing
        SLOG.info "#{DateTime.now.to_s(:db)} world #{world.id} marked for processing"
        world.save!
      end
    end
  end

  def self.turn_next_world
    SLOG.info "check for turnables"
    world = World.ready_for_processing.first
    if world
      SLOG.info "#{DateTime.now.to_s(:db)} turning #{world.id}"
      Jobs::WorldTurner.turn_a_world(world)
    end
  end
end
