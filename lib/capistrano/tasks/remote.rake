namespace :remote do
  desc 'Run a remote rake task, example: "cap staging remote:rake[db:version]"'
  # run like: cap staging remote:rake[db:version]
  # NOTE: if you try to use square brackets on zsh you'll get: 'Zsh: No Matches Found'
  #   to re-enable, add this to your .zshrc 'alias cap="noglob cap"'
  task :rake, [:task] do |_t, args|
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, args.task
        end
      end
    end
  end

  desc 'Run a remote command, example: "cap production remote:cmd[ps,aux]"'
  task :cmd, [:cmd, :options] do |_t, args|
    on primary fetch(:migration_role) do
      within release_path do
        execute args.cmd.to_sym, args.options
      end
    end
  end
end
