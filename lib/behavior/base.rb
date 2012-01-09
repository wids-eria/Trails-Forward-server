module Behavior
  module Base
    def self.included(base)
      base.extend ClassMethods
    end

    def fecundity
      0
    end

    def mortality_rate
      0
    end

    def survival_rate
      1 - mortality_rate
    end

    module ClassMethods
      def fecundity val
        define_method :fecundity do
          val
        end
      end

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
