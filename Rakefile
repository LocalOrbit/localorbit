# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)

Rails.application.load_tasks

namespace :db do
  namespace :seed do
    desc "Loads a basic set of development data"
    task development: [:environment] do
      require File.join Rails.root, "db", "seeds"
      require File.join Rails.root, "db", "seeds", "development"
    end
  end

  namespace :rebuild do
    desc "Re-creates the development database from the db/seeds/development.rb file"
    task development: [:reset, "seed:development"] do
      puts "Rebuilt the development database..."
    end
  end
end
