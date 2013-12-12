namespace :console do
  desc "Rails console for localorbit on staging"
  task :staging do
    app = "localorbit-staging"
    remote = "git@heroku.com:#{app}.git"

    Bundler.with_clean_env do
      exec "heroku run --app #{app} rails console"
    end
  end

  desc "Rails console for localorbit on production"
  task :production do
    app = "localorbit"
    remote = "git@heroku.com:#{app}.git"

    Bundler.with_clean_env do
      exec "heroku run --app #{app} rails console"
    end
  end
end
