namespace :admin do
  desc "Cleanup failed payments and order history"
  task :cleanup_refunds do
    deploy_env = "localorbit-production"
    # deploy_env = "localorbit-dev3"
    exec "heroku run rails runner tools/admin/cleanup_refunds.rb --app #{deploy_env}"
  end
end
