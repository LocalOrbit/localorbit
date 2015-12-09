source "https://rubygems.org"

ruby "2.1.2"

gem "rails", "~> 4.1.6.rc1"

gem "pg"

# Assets
gem "sass-rails",   "~> 4.0.0"
gem "uglifier",     ">= 1.3.0"
gem "coffee-rails", "~> 4.0.0"

# The jQuery update is doing something weird
# with data confirms and poltergeist
gem "jquery-rails", "< 3.1.1"
gem "jquery-ui-rails"
gem "accountingjs-rails"
gem "compass-rails"
gem "underscore-rails"
gem "wysihtml5-rails"
gem "mapbox-rails"


gem "active_model_serializers"
gem "active_record_union"
gem "acts_as_geocodable"
gem "audited-activerecord"
gem "awesome_nested_set"
gem "balanced", "~> 0.7"
gem "stripe"
gem "color"
gem "countries"
gem "csv_builder"
gem "delayed_job"
gem "delayed_job_active_record"
gem "devise"
gem "devise_invitable"
gem "devise_masquerade"
gem "dragonfly-s3_data_store"
gem "draper"
gem "figaro", "~> 1.0.0.rc1"
gem "font_assets"
gem "graticule"
gem "honeybadger"
gem "groupdate", github: "trestrantham/groupdate", branch: "custom-calculations" # Waiting on https://github.com/ankane/groupdate/pull/53
gem "interactor-rails", "< 3.0"
gem "interactor", "< 3.0" # We are not ready for 3 yet
gem 'intercom-rails', '~> 0.2.26'
gem 'intercom', '~> 2.3.0'
gem "jbuilder"
gem "jwt"
gem "kaminari"
gem "newrelic_rpm", "< 3.9.0" # Rack middleware instrumentation is very broken
gem "newrelic-dragonfly"
gem "pdfkit"
gem "periscope-activerecord"
gem "pg_search"
gem "postgres_ext"
gem "rack-canonical-host"
gem "ransack"
gem "simpleidn"
gem "stripe_event"
gem 'react-rails', '~> 1.0'
gem "font-awesome-rails"
gem "wysiwyg-rails"
gem "kiba"

gem "constructor"
gem "tabulator", github: "dcrosby42/tabulator"
gem "rschema", github: "tomdalling/rschema"

# wkhtmltopdf versions are a mess. 0.12.1 is stable but not well supported by gems
# See https://github.com/zakird/wkhtmltopdf_binary_gem/issues/13
# The github version is massive and makes the Heroku slug huge
# gem "wkhtmltopdf-binary"
#gem "wkhtmltopdf-binary", github: "zakird/wkhtmltopdf_binary_gem"

# Product import/export
gem 'rubyXL', require: false # XLSX
gem 'spreadsheet', require: false # XLS
gem 'slop', '~> 3.0', require: false # option parsing
gem 'dedent', require: false
gem 'activerecord-import', require: false
gem 'grape' # API v2
gem 'grape-active_model_serializers' # API v2
gem 'rack-cors', :require => 'rack/cors' # API v2

group :doc do
  gem "sdoc", require: false
end

group :development do
  gem "bullet"
  gem "ultrahook"
  gem "spring"
  gem "spring-commands-rspec"
  gem "rubocop", require: false
  gem "quiet_assets"
  gem "aws-sdk"
  gem "rails_view_annotator"
  gem "unicorn"
  gem "mailcatcher"
end

group :development, :test do
  gem "rspec-rails", "~> 3.0"
  gem "rspec-collection_matchers"
  gem 'rspec_junit_formatter', :git => 'https://github.com/circleci/rspec_junit_formatter'
  gem "pry-rails"
  gem "pry-remote"
  gem "byebug"
  gem "pry-byebug"
  gem "launchy"
  gem "guard-rspec"
  gem "guard-konacha-rails"
  gem "awesome_print"
  gem "konacha"
  gem "konacha-chai-matchers"
  gem "poltergeist"
  gem "webmock"
  gem 'capybara-slow_finder_errors'
  #gem 'wkhtmltopdf-binary-edge', '~> 0.12.2.1'
  gem "wkhtmltopdf-binary", github: "zakird/wkhtmltopdf_binary_gem"
end

group :test do
  gem "codeclimate-test-reporter", require: false
  gem "simplecov", require: false
  gem "capybara"
  gem "domino"
  gem "factory_girl_rails"
  gem "email_spec"
  gem "database_cleaner"
  gem "timecop"
  gem "vcr"
  gem 'fire_poll', '1.2.0'
end

group :production, :staging do
  gem "passenger"
  gem "rack-cache", require: "rack/cache"
  gem "rails_12factor"
  gem "pgbackups-archive"
  gem "heroku-api"
  gem 'wkhtmltopdf-heroku'
end
