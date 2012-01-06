module Behavior
  module TransitionMatrix
    def life_state= val
      @life_state = val
    end

    def life_state
      @life_state ||= 0
    end

    def try_survival!
      die! unless survive?
    end

    def base_survival_probability
      daily_survival_probabilities[life_state]
    end

    def survive?
      rand < base_survival_probability
    end

    def base_transition_probability
      daily_transition_probability[life_state]
    end

    def try_transition!
      @life_state += 1 if rand < daily_transition_probability
    end

    def reproduce?
      self.age % 365 == 0
    end

    def litter_size
      litter_size_probability = litter_size_probabilities[life_state]
      large_litter = rand < litter_size_probability[1]
      litter_size_probability[0] + (large_litter ? 1 : 0)
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
          matrix[0].map { |p| p.divmod 1.0 }
        end
      end
    end
  end
end
