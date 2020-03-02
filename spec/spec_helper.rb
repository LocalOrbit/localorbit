require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/vendor/'
  add_filter '/config/'
  add_filter '/spec/'
  add_filter '/db/'
  add_filter '/app/mailers/'
  add_filter '/app/helpers/'
  add_filter '/app/uploaders/'
end

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "email_spec"
require "pundit/rspec"

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f }

StripeMock.webhook_fixture_path = './spec/fixtures/webhooks/stripe/'

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  # Store status of last run so we can use --only-failures and --next-failure
  config.example_status_persistence_file_path = "examples.txt"
  config.run_all_when_everything_filtered = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explictly tag your specs with their type, e.g.:
  #
  #     describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/v/3-0/docs
  config.infer_spec_type_from_file_location!

  config.include FactoryBot::Syntax::Methods
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
  config.include ChosenJs::Helpers, chosen_js: true
  config.include FirePoll
  config.include PauseHelpers, type: :feature
  config.include DropdownHelpers, type: :feature
  config.include StripeWebhooksHelpers, type: :request
  config.include WebhookHelpers, type: :request

  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    ImportLegacyTaxonomy.run(Rails.root.join("db/taxonomy_truncated.csv"))
    ImportRoleActions.run(Rails.root.join("db/role_actions.csv"))
  end

  config.before(:each) do
    ActionMailer::Base.deliveries.clear
  end
end
