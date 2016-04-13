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

  config.around( :each ) do |spec|
    if spec.metadata[:js]
      # JS => doesn't share connections => can't use transactions
      spec.run
      DatabaseCleaner.clean_with :deletion
    else
      # No JS/Devise => run with Rack::Test => transactions are ok
      DatabaseCleaner.start
      spec.run
      DatabaseCleaner.clean

      # see https://github.com/bmabey/database_cleaner/issues/99
      begin
        ActiveRecord::Base.connection.send :rollback_transaction_records, true
      rescue
      end
    end
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:all, truncate_after_all: true) do
    DatabaseCleaner.clean_with(:truncation, except: %w(categories))
  end
end
