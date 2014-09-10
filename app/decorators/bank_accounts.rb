module Decorators
  module BankAccounts
    def payble_accounts_for_select
      bank_accounts.visible.where(account_type: %w(savings checking)).map do |bank_account|
        [bank_account.display_name, bank_account.id]
      end
    end

    def payment_accounts_for_select
      bank_accounts.visible.map do |bank_account|
        next unless bank_account.usable_for?(:debit)
        [bank_account.display_name, bank_account.id]
      end.compact
    end
  end
end