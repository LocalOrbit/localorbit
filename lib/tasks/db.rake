namespace :db do

  namespace :seed do
    desc "Loads a basic set of development data"
    task development: [:environment] do
      require File.join Rails.root, "db", "seeds", "development"
    end
  end

  namespace :rebuild do
    desc "Re-creates the development database from the db/seeds/development.rb file"
    task development: [:reset, "seed:development"] do
      puts "Rebuilt the development database..."
    end
  end

  namespace :dump do
    desc "Overwrites your development database w/ data from staging, and sets all user passwords to 'password1'"

    task staging: [:environment] do
      install_plugins = "heroku plugins:install https://github.com/ddollar/heroku-pg-transfer"
      update_pg_plugins = "heroku plugins:update"
      system_command = "env DATABASE_URL=postgres://localhost/#{ActiveRecord::Base.connection.current_database} heroku pg:transfer --confirm localorbit-staging"

      system(install_plugins)
      system(update_pg_plugins)
      system(system_command)

      # This works for local dev data
      # NEVER USE ON A SERVER
      User.update_all(encrypted_password: Devise.bcrypt(User, "password1"))

      # Triggers all app files to load
      Rails.application.config.eager_load_namespaces.each(&:eager_load!)

      # By triggering all models to load we can auto detect uploads we need to process
      uploads = Dragonfly::Model::Attachment.descendants.map {|i| [i.model_class, i.attribute] }

      uploads.each do |klass, field|
        scope = klass.where.not("#{field}_uid" => nil)
        total = scope.count
        scope.find_each.each_with_index do |item, idx|
          begin
            item.send(field).job.fetch_step.apply
            puts "#{klass}/#{field} (#{idx + 1}/#{total}) Already downloaded"
          rescue
            puts "#{klass}/#{field} (#{idx + 1}/#{total}) Downloading"
            uid = item.send(field).job.uid
            image = Dragonfly.app.fetch_url("https://s3-us-west-2.amazonaws.com/localorbit-uploads-staging/#{uid}")
            image.store(path: uid)
          end
        end
      end
    end
  end
end
