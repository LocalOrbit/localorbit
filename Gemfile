source 'https://rubygems.org'

ruby '2.1.2'

gem 'rails', '~> 4.1.4'

gem 'pg'
gem 'mysql2'

# Assets
gem 'sass-rails',   '~> 4.0.0'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'

# The jQuery update is doing something weird
# with data confirms and poltergeist
gem 'jquery-rails', '< 3.1.1'
gem 'jquery-ui-rails'
gem 'accountingjs-rails'
gem 'compass-rails'
gem 'underscore-rails'
gem 'wysihtml5-rails'

gem "active_model_serializers"
gem "acts_as_geocodable", github: 'collectiveidea/acts_as_geocodable'
gem 'awesome_nested_set', github: 'collectiveidea/awesome_nested_set'
gem "balanced", "~> 0.7"
gem "countries"
gem "csv_builder"
gem "dalli"
gem "delayed_job"
gem "delayed_job_active_record"
gem 'devise'
gem 'devise_invitable'
gem 'dragonfly-s3_data_store'
gem 'draper'
gem 'figaro', '~> 1.0.0.rc1'
gem 'font_assets'
gem "graticule", github: 'collectiveidea/graticule'
gem 'honeybadger', '1.14.0'
gem 'interactor-rails'
gem 'jbuilder'
gem 'jwt'
gem 'kaminari'
# Rack middleware instrumentation is very broken
gem 'newrelic_rpm', '< 3.9.0'
gem 'newrelic-dragonfly'
gem 'pdfkit'
gem 'periscope-activerecord'
gem 'pg_search'
gem 'rack-canonical-host'
gem 'ransack', github: 'activerecord-hackery/ransack', branch: 'rails-4.1'
gem 'simpleidn'
gem 'wkhtmltopdf-binary'

group :doc do
  gem 'sdoc', require: false
end

group :development do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rubocop', require: false
  gem 'quiet_assets'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'rspec-collection_matchers'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'launchy'
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', '~> 0.7.1',     require: false
  gem 'capybara'
  gem 'domino'
  gem 'factory_girl_rails'
  gem 'email_spec'
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :production, :staging do
  gem "passenger"
  gem 'rack-cache', require: 'rack/cache'
  gem 'rails_12factor'
  gem 'pgbackups-archive'
  gem 'heroku-api'
end
