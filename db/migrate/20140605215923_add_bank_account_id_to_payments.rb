class AddBankAccountIdToPayments < ActiveRecord::Migration
  class Payment < ActiveRecord::Base; end
  class BankAccount < ActiveRecord::Base; end

  def up
    add_column :payments, :bank_account_id, :integer
    Payment.reset_column_information

    count = 0
    Payment.where.not(balanced_uri: nil).find_each do |payment|
      begin
        transaction = Balanced::Transaction.find(payment.balanced_uri)
        uri = case transaction
        when Balanced::Credit
          transaction.bank_account.uri
        when Balanced::Refund
          transaction.debit.source_uri
        when Balanced::Debit
          transaction.source.uri
        else
          puts "Unknown transaction type \"#{transaction.class}\" for payment id #{payment.id}"
          next
        end
        bank_accounts = BankAccount.where("balanced_uri LIKE '%/#{uri.split('/').last}'")

        if bank_accounts.size == 1
          payment.update_attribute(:bank_account_id, bank_accounts.first.id)
        elsif bank_accounts.size > 1
          puts "Found #{bank_accounts.size} matches for payment id #{payment.id}"
        else
          puts "Could not find a bank account for payment id #{payment.id} with balanced uri #{payment.balanced_uri}"
        end
      rescue => e
        puts "Update of payment id #{payment.id} failed with: #{e.inspect}"
      end
      count += 1
    end

    puts "Reviewed #{count} payment records"
    end_count = Payment.where.not(balanced_uri: nil).count
    if end_count > count
      puts "!!! WARNING: #{end_count - count} payment records were created while this migration ran"
    end
  end

  def down
    remove_column :payments, :bank_account_id
  end
end
