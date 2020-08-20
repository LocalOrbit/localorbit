namespace :delayed_job do
  desc 'Restart delayed_job'
  task :restart do
    on roles(fetch(:delayed_job_server_role, :worker)) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :sudo, '/bin/systemctl', :restart, :'delayed_job_default@0'
          execute :sudo, '/bin/systemctl', :restart, :'delayed_job_urgent@0'
        end
      end
    end
  end
end
