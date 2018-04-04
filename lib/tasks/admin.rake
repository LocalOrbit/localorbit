namespace :admin do
  desc "Cleanup failed payments and order history"
  task :cleanup_refunds do
    rails_env = "localorbit-production"
    # rails_env = "localorbit-dev3"
    exec "heroku run rails runner tools/admin/cleanup_refunds.rb --app #{rails_env}"
  end
end
