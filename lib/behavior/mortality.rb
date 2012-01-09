module Behavior
  module Mortality
    def die?
      rand < self.mortality_rate
    end

    def die
      self.destroy
    end

    def mortality_rate
      0
    end

    def survival_rate
      1 - mortality_rate
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def mortality_rate val
        define_method :mortality_rate do
          1 - (1 - val) ** (1.0/365)
        end
      end

      def survival_rate val
        mortality_rate 1.0 - val
      end
    end
  end
end
