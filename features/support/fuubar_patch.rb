module Cucumber::Cli::Configuration::Patch
  def self.included(base)
    base.class_eval do
      alias_method :_orig_formatter_class, :formatter_class

      def formatter_class(format)
        if format == 'fuubar'
          require 'cucumber/formatter/fuubar'
          Cucumber::Formatter::Fuubar
        else
          _orig_formatter_class(format)
        end
      end
    end
  end
end

Cucumber::Cli::Configuration.send(:include, Cucumber::Cli::Configuration::Patch)
