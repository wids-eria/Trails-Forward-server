module Behavior
  module Mortality
    def die?
      rand < self.daily_mortality_rate
    end

    def die
      self.destroy
    end

    # Default to 100% survival until DSL overrides
    def annual_survival_rate tile = resource_tile
      1
    end

    def annual_mortality_rate tile = resource_tile
      1 - annual_survival_rate(tile)
    end

    def daily_survival_rate tile = resource_tile
      annual_survival_rate(tile) ** (1 / 365.0)
    end

    def daily_mortality_rate tile = resource_tile
      1 - daily_survival_rate(tile)
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def annual_mortality_rate val
        annual_survival_rate(1 - val)
      end

      def annual_survival_rate val
        define_method :annual_survival_rate do |tile = nil|
          val
        end
      end
    end
  end
end
