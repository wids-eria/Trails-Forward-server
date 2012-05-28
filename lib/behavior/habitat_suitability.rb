module Behavior
  module HabitatSuitability
    def annual_survival_rate_with_suitability tile = resource_tile
      annual_survival_rate_without_suitability(tile) * suitability_survival_modifier
    end

    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        alias_method :annual_survival_rate_without_suitability, :annual_survival_rate unless method_defined?(:annual_survival_rate_without_suitability)
        alias_method :annual_survival_rate, :annual_survival_rate_with_suitability
      end
    end

    def habitat_suitability_for tile
      habitat_suitability(tile.landcover_class_code) if tile && tile.landcover_class_code
    end

    module ClassMethods
      def habitat_suitability habitat_hash = {}
        define_method :habitat_suitability_hash do
          @habitat_suitability = Hash[ResourceTile.cover_types.values.map {|v| [v,5.0]}].merge habitat_hash
        end

        define_method :habitat_suitability do |cover_code|
          case cover_code.class.name
          when "Symbol"
            habitat_suitability_hash[cover_code]
          else
            habitat_suitability_hash[ResourceTile.cover_types[cover_code.to_i]]
          end
        end
      end


      def suitability_survival_modifier default = nil, &blk
        define_method :suitability_survival_modifier_for do |tile|
          suitability = habitat_suitability_for(tile)
          suitability ? blk.call(suitability) : default
        end

        define_method :suitability_survival_modifier do
          suitability_survival_modifier_for resource_tile
        end
      end

      def suitability_fecundity_modifier default = nil, &blk
        define_method :suitability_fecundity_modifier_for do |tile|
          suitability = habitat_suitability_for(tile)
          suitability ? blk.call(suitability) : default
        end

        define_method :suitability_fecundity_modifier do
          suitability_fecundity_modifier_for resource_tile
        end
      end
    end
  end
end
