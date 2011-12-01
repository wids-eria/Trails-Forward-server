require 'database_cleaner'
DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.before(:all) do
    DatabaseCleaner.start # usually this is called in setup of a test
  end
  config.before(:each) do
    DatabaseCleaner.clean # cleanup the db
  end
end
