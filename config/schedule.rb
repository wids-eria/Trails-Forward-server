every "* * * * *" do
  runner "TurnScheduler.mark_for_processing"
end

every "* * * * *" do
  runner "TurnScheduler.turn_next_world"
end
