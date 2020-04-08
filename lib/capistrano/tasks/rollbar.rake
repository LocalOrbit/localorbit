require 'dotenv/tasks'

task notify_rollbar: :dotenv do
  on roles(:app) do |_h|
    revision = `git log -n 1 --pretty=format:"%H"`
    local_user = `whoami`.chomp
    rollbar_token = ENV.fetch('ROLLBAR_ACCESS_TOKEN')
    rails_env = fetch(:rails_env, 'production')
    execute :curl, "https://api.rollbar.com/api/1/deploy/ -F access_token=#{rollbar_token} -F environment=#{rails_env} -F revision=#{revision} -F local_username=#{local_user} >/dev/null 2>&1", :once => true
  end
end
