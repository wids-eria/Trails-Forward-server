require 'factory_girl/syntax/methods'

RSpec.configure do |config|
  config.mock_with :mocha
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include FactoryGirl::Syntax::Methods
end
