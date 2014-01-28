RSpec.configure do |config|
  config.around(:each) do |example|
    DatabaseCleaner.strategy = :transaction

    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end

  config.around(:each, js: true) do |example|
    DatabaseCleaner.strategy = :truncation, {:except => %w(categories)}

    DatabaseCleaner.start
    example.run
    DatabaseCleaner.clean
  end
end
