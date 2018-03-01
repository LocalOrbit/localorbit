# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
# TODO: Remove this when we upgrade to rails 5.2
require 'bootsnap/setup' if ENV["RAILS_ENV"] == 'test' || ENV["RAILS_ENV"] == 'development'
