require 'set'
w = World.find 4

w.players.each do |p|
	p.contracts.each do |c|
		s = Set.new
		c.included_megatile_ids.each do |id|
			s << id
		end
		c.included_megatiles.clear
		puts "Contract #{c.id} megatile IDs: #{s.map do |foo| foo end}"
		s.each do |id|
		  mt = Megatile.find id
		  unless c.is_satisfied?
		    mt.owner = p
		    mt.save!
		  end
		  c.included_megatiles << mt
		end
	end
end