RSpec.configure do |config|
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation, {except: %w(categories)}
  end

  config.before(:each, truncate: true) do
    DatabaseCleaner.strategy = :truncation, {except: %w(categories)}
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:all, truncate_after_all: true) do
    DatabaseCleaner.clean_with(:truncation, except: %w(categories))
  end
end
