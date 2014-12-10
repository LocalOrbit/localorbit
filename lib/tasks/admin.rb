namespace :admin do
  desc "Clean up failed payments and order history"
  task :cleanup_payments do
    exec "heroku run rails runner tools/admin/cleanup_payments.rb --app localorbit-production"
  end
end
