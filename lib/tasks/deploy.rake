namespace :deploy do
  desc "Deploy localorbit to staging"
  task :staging do
    app = "localorbit-staging"
    remote = "git@heroku.com:#{app}.git"

    system "git push #{remote} rails:master"
    system "heroku run --app #{app} bundle exec rake db:migrate"
    system "heroku restart --app #{app}"
  end

  desc "Deploy localorbit to production"
  task :production do
    app = "localorbit"
    remote = "git@heroku.com:#{app}.git"

    system "git push #{remote} rails:master"
    system "heroku run --app #{app} bundle exec rake db:migrate"
    system "heroku restart --app #{app}"
  end
end
