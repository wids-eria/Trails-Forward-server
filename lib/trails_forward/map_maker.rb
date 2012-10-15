module TrailsForward
  module MapMaker
    def color
      return @color if @color
      mixed_forest = ChunkyPNG::Color :dark_green
      deciduous_mix = ChunkyPNG::Color :yellow
      coniferous_mix = ChunkyPNG::Color :dark_blue
      deciduous_forest = blend mixed_forest, deciduous_mix, 0.8
      coniferous_forest = blend mixed_forest, coniferous_mix, 0.8
      @color = { agent: ChunkyPNG::Color(:red),
                 light_water: ChunkyPNG::Color(:blue),
                 dark_water: ChunkyPNG::Color(:dark_blue),
                 marshland: ChunkyPNG::Color(2, 117, 110),
                 ground: ChunkyPNG::Color(:dark_khaki),
                 mixed_forest: mixed_forest,
                 deciduous_forest: deciduous_forest,
                 coniferous_forest: coniferous_forest,
                 imperviousness: ChunkyPNG::Color(70, 35, 10),
                 housing_density: ChunkyPNG::Color(50, 50, 50),
                 error: ChunkyPNG::Color(:magenta) }
    end



    def generate_png filename
      canvas = to_png

      canvas.save filename
    end

    def to_png
      canvas = ChunkyPNG::Image.new width, height, color[:ground]

      if Rails.env.development?
        prog_bar = ProgressBar.new("Mapping #{resource_tiles.count} tiles", resource_tiles.count)
        prog_bar.expand_title
        prog_bar.colorize :cyan
      end
      resource_tiles.with_agents.find_in_batches do |tiles|
        tiles.each do |tile|
          x, y = tile.location
          canvas[x, y] = color_tile tile
        end
        prog_bar.inc tiles.size if Rails.env.development?
      end
      prog_bar.finish if Rails.env.development?

      canvas
    end

  private

    def color_tile tile
      base_color = case tile.type
                   when WaterTile.to_s then water_color(tile)
                   when LandTile.to_s
                     if tile.tree_density > 0.01
                       forest_color(tile)
                     else
                       urban_color(tile)
                     end
                   else
                     color[:error]
                   end

      if tile.agents.any?
        base_color = blend base_color, color[:agent], [tile.agents.count / 4.0, 1].min
      end

      base_color
    end

    def blend foreground, background, blend_alpha
      ChunkyPNG::Color.interpolate_quick foreground, background, (blend_alpha * 256).to_i
    end

    def water_color tile
      if tile.landcover_class_code == 95
        percent_color = (5.0 - (tile.soil || 0)) / 5.0
        blend color[:marshland], color[:ground], percent_color
      else
        blend color[:light_water], color[:dark_water], rand / 4
      end
    end

    def forest_color tile
      this_green = case tile.land_cover_type.to_sym
                   when :deciduous then color[:deciduous_forest]
                   when :coniferous then color[:coniferous_forest]
                   else @color[:mixed_forest]
                   end
      blend this_green, color[:ground], tile.tree_density
    end

    def urban_color tile
      impervious_alpha = (tile.imperviousness || 0) * 0.8
      housing_alpha = case tile.housing_type
      when nil
        0
      when "vacation", "single family"
        0.4
      when "apartment"
        0.8
      end
      ground_color = blend color[:imperviousness], color[:ground], impervious_alpha
      blend color[:housing_density], ground_color, housing_alpha
    end
  end
end
