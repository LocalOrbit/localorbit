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

  config.after(:each, js: true) do
    current_path.should == current_path
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
