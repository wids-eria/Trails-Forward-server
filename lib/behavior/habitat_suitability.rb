module Behavior
  module HabitatSuitability
    def base_survival_probability_with_habitat_suitabiltiy
      self.base_survival_probability * habitat_suitability_modifier
    end

    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
      end
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

      def suitability_survival_modifier &blk
        define_method :suitability_survival_modifier_for do |tile|
          blk.call(habitat_suitability tile.land_cover_type)
        end

        define_method :suitability_survival_modifier do
          suitability_survival_modifier_for self.resource_tile
        end
      end

      def suitability_fecundity_modifier &blk
        define_method :suitability_fecundity_modifier_for do |tile|
          blk.call(habitat_suitability tile.land_cover_type)
        end

        define_method :suitability_fecundity_modifier do
          suitability_fecundity_modifier_for self.resource_tile
        end
      end
    end
  end
end
