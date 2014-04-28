namespace :balanced do
  desc "Check Balanced to see if ACH payments have succeeded/failed"
  task check_ach_status: :environment do
    Payment.where(payment_type: 'ach', status: 'pending').each do |payment|

      begin
        debit = Balanced::Debit.find(payment.balanced_uri)
        if debit.status != 'pending'
          UpdatePaymentStatus.perform(payment: payment, debit: debit)
        end

      rescue
      end

    end
    
    Snitcher.snitch("d159854152")
  end

end
