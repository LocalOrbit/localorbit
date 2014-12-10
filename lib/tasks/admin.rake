namespace :admin do
  desc "Cleanup failed payments and order history"
  task :cleanup_payments do
    exec "heroku run rails runner tools/admin/cleanup_payments.rb --app localorbit-dev3"
  end
end
