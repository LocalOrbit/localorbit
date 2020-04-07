set :stage, :build
set :branch, :aws_deploy
set :rails_env, :build

server 'build.localorbit.com', user: 'localorbit', roles: %w[web app db worker migrator]
