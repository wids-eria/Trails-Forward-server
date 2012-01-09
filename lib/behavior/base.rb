module Behavior
  module Base
    def self.included(base)
      base.send :include, Behavior::Reproduction
      base.send :include, Behavior::Mortality
    end
  end
end
