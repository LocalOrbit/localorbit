namespace :deploy do
  def parse_deploy(deploy)
    deploy.scan(/(v[0-9]+)  Deploy ([0-9a-f]+)/)[0]
  end

  def finish_deploy(app, tag_prefix)
    Bundler.with_clean_env do
      deploys = `heroku releases --app #{app} | grep "Deploy"`.split("\n")
      # Previous deploy
      version, sha = parse_deploy(deploys[1])

      `git diff #{sha} --name-only | grep -E "^db/migrate"`
      if $?.exitstatus == 0
        system "heroku run --app #{app} rake db:migrate"
        system "heroku restart --app #{app}"
      else
        puts "No migrations detected"
      end

      # Current deploy
      version, sha = parse_deploy(deploys[0])
      system "git tag #{tag_prefix}#{version}"
      system "git push --tags"
    end
  end

  desc "Deploy localorbit to staging"
  task :staging do
    app = "localorbit-staging"
    remote = "git@heroku.com:#{app}.git"

    system "git push -f #{remote} master"
    finish_deploy(app, "staging-")
  end

  desc "Deploy localorbit to production"
  task :production do
    app = "localorbit-production"
    remote = "git@heroku.com:#{app}.git"

    system "git checkout production"
    system "git push -f #{remote} production:master"
    finish_deploy(app, "")
  end
end
