module Behavior
  module TransitionMatrix
    def life_state= val
      @life_state = val
    end

    def life_state
      @life_state ||= 0
    end

    def base_transition_probability
      daily_transition_probability[life_state]
    end

    def try_transition!
      @life_state += 1 if rand < daily_transition_probability
    end

    def fecundity
      litter_size_probabilities[life_state]
    end

    def tick_with_state_transition_check
      self.life_state = 1 if self.life_state == 0 && self.age >= 365
      tick_without_state_transition_check
    end

    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval do
        alias_method :tick_without_state_transition_check, :tick unless method_defined?(:tick_without_state_transition_check)
        alias_method :tick, :tick_with_state_transition_check
      end
    end

    module ClassMethods
      def transition_matrix matrix
        define_method :daily_survival_probabilities do
          matrix[-1].map {|p| p ** (1/365.0)}
        end

        define_method :litter_size_probabilities do
          matrix[0]
        end
      end
    end
  end
end
