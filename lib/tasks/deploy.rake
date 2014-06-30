namespace :deploy do
  desc "Deploy localorbit to staging"
  task :staging do
    app = "localorbit-staging"
    remote = "git@heroku.com:#{app}.git"

    system "git push -f #{remote} master"
    Bundler.with_clean_env do
      system "heroku run --app #{app} rake db:migrate"
      system "heroku restart --app #{app}"

      version = `heroku releases --app #{app} -n 1 | grep -o '^v[0-9]*'`
      system "git tag staging-#{version}"
      system "git push --tags"
    end
  end

  desc "Deploy localorbit to production"
  task :production do
    app = "localorbit-production"
    remote = "git@heroku.com:#{app}.git"

    system "git checkout production"
    system "git push -f #{remote} production:master"
    Bundler.with_clean_env do
      system "heroku run --app #{app} rake db:migrate"
      system "heroku restart --app #{app}"

      version = `heroku releases --app #{app} -n 1 | grep -o '^v[0-9]*'`
      system "git tag #{version}"
      system "git push --tags"
    end
  end
end
