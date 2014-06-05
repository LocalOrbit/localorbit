namespace :balanced do
  desc "Check Balanced to see if ACH payments have succeeded/failed"
  task check_ach_status: :environment do
    UpdatePaymentStatus.perform
  end
end
