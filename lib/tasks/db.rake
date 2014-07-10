namespace :db do
  namespace :dump do
    desc "Overwrites your development database w/ data from staging, and sets all user passwords to 'password1'"

    task :staging => [:environment] do
      install_plugins = "heroku plugins:install https://github.com/ddollar/heroku-pg-transfer"
      update_pg_plugins = "heroku plugins:update"
      system_command = "env DATABASE_URL=postgres://localhost/#{ActiveRecord::Base.connection.current_database} heroku pg:transfer --confirm localorbit-staging"

      system(install_plugins)
      system(update_pg_plugins)
      system(system_command)

      # This works for local dev data
      # NEVER USE ON A SERVER
      User.update_all(encrypted_password: Devise.bcrypt(User, "password1"))

    end
  end
end
