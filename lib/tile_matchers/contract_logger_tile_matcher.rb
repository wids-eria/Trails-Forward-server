class ContractLoggerTileMatcher < LoggerTileMatcher
  def find_candidate_megatiles_helper(contract)
    case contract.contract_template.wood_type
    when "pole_timber"
      type = :poletimber_volume
    when "saw_timber"
      type = :sawtimber_volume
    else
      puts "Wrong wood type"
      return []
    end
    required = contract.contract_template.volume_required
    unowned_megatiles = contract.world.megatiles.where(:owner_id => nil).order("RAND()").limit(2000)
    candidate_megatiles = []
    unowned_megatiles.each do |mtile|
      volume = 0
      num_rts = 0
      mtile.resource_tiles.where(:type => "LandTile").each do |rt|
        begin
          if rt.tree_density > 0.0
            cur_vol = rt.total_wood_values_and_volumes[type]
            if cur_vol > 0 && volume < required
              num_rts += 1
            end
            volume += cur_vol
          end
        rescue
          next
        end
      end
      if volume > 0
        candidate_megatiles << { megatile_id: mtile.id, x: mtile.x, y: mtile.y,
                                 volume: volume }
      end
    end
    candidate_megatiles.sort_by! {|e| -e[:volume]}
  end

  def find_best_megatiles_for_contract(contract)
    mtiles = find_candidate_megatiles_helper(contract)
    return [] if mtiles.count == 0

    required = contract.contract_template.volume_required
    case contract.contract_template.difficulty
    when "easy"
      required_num_tiles = 1
    when "normal", "medium"
      required_num_tiles = 2
    when "hard"
      required_num_tiles = 3
    when "pro", "professional"
      required_num_tiles = 4
    end

    mtiles.each do |m|
      adj_mtiles = mtiles.select {|e| m[:x]-3 <= e[:x] && e[:x] <= m[:x]+3 && m[:y]-3 <= e[:y] && e[:y] <= m[:y]+3}
      cum_vol = m[:volume]
      mark = (cum_vol >= required)? 1 : -1
      final_mtiles = [m]

      adj_mtiles.each do |adjm|
        if m == adjm
          next
        end
        cum_vol += adjm[:volume]
        final_mtiles << adjm
        if mark == -1 && cum_vol >= required
          mark = final_mtiles.count
        end
      end

      if cum_vol >= required && final_mtiles.count >= required_num_tiles
        mark = (mark > required_num_tiles) ? mark : required_num_tiles
#        contract.included_megatiles << final_mtiles.find(0, mark-1)
        return final_mtiles[0..mark-1]
      end
    end
    return []
  end
end
