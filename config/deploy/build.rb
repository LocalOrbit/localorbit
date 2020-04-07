set :stage, :build
set :branch, :build
set :rails_env, :build

server 'build.localorbit.com', user: 'localorbit', roles: %w[web app db worker migrator]
