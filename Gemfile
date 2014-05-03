source 'https://rubygems.org'

ruby '2.1.1'

gem 'rails', '4.1.0'

gem 'pg'
gem 'mysql2'

# Assets
gem 'sass-rails',   '~> 4.0.0'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
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
gem 'devise'
gem 'devise_invitable'
gem 'dragonfly-s3_data_store'
gem 'draper'
gem 'faraday', '< 0.9.0' # 0.9.0 does not work with balanced 0.8.1
gem 'figaro', '~> 1.0.0.rc1'
gem 'font_assets'
gem "graticule", github: 'collectiveidea/graticule'
gem 'honeybadger'
gem 'interactor-rails'
gem 'jbuilder'
gem 'kaminari'
gem 'newrelic_rpm'
gem 'pdfkit'
gem 'periscope-activerecord'
gem 'rack-canonical-host'
gem 'simpleidn'
gem 'wkhtmltopdf-binary'

group :doc do
  gem 'sdoc', require: false
end

group :development do
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rubocop', require: false
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0.0.beta2'
  gem 'pry-rails'
  gem 'pry-remote'
  gem 'launchy'
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'simplecov', '~> 0.7.1',     require: false
  gem 'capybara', github: 'jnicklas/capybara' # until gem > 2.2.1 is out
  gem 'domino'
  gem 'factory_girl_rails'
  gem 'email_spec', github: 'bmabey/email-spec' # until gem > 1.5.0 is out
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :production, :staging do
  gem 'unicorn', require: false
  gem 'rails_12factor'
  gem 'pgbackups-archive'
  gem 'heroku-api'
end
