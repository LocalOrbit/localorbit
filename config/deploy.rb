# config valid for current version and patch releases of Capistrano
lock "~> 3.12.1"

set :application, "localorbit"
set :repo_url, "git@github.com:LocalOrbit/localorbit.git"

set :passenger_restart_with_sudo, true
# need this variable because 16.04 has private tmp dir
set :passenger_restart_command, 'PASSENGER_INSTANCE_REGISTRY_DIR=/var/run/passenger-instreg passenger-config restart-app'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, '/srv/www/app.localorbit.com'
set :release_path, deploy_path.join('localorbit')

set :migration_role, :migrator

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system db/dumps]

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

namespace :deploy do
  desc 'Restart application'
end

after :deploy, :notify_rollbar
