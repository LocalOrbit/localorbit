source 'https://rubygems.org'

ruby '2.1.0'

gem 'rails', '4.0.2'

gem 'pg'

# Assets
gem 'sass-rails',   '~> 4.0.0'
gem 'uglifier',     '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'compass-rails'

gem "active_model_serializers"
gem "countries"
gem 'devise'
gem 'devise_invitable'
gem 'draper'
gem 'figaro',       github: 'laserlemon/figaro'
gem 'honeybadger'
gem 'interactor-rails'
gem 'newrelic_rpm'
gem 'jquery-ui-rails'

group :doc do
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'rspec-rails', '~> 2.14.0'

  # Use debugger
  gem 'debugger'
  gem 'pry-rails'
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
end

group :production, :staging do
  gem 'unicorn', require: false
  gem 'rails_12factor'
end
