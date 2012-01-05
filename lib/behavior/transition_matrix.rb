module Behavior
  module TransitionMatrix
    def self.included(base)
      base.extend(ClassMethods)
    end

    def life_state= val
      @life_state = val
    end

    def life_state
      @life_state ||= 0
    end

    def try_survival!
      die! unless survive?
    end

    def survive?
      rand < daily_survival_probabilities[life_state]
    end

    def die!
      self.class.delete(self.id) unless new_record?
    end

    def try_transition!
      @life_state += 1 if (rand < daily_transition_probabilities[life_state])
    end

    def litter_size
      litter_size_probability = litter_size_probabilities[life_state]
      result = litter_size_probability[0]
      result += 1.0 if (rand < litter_size_probability[1])
      result
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
